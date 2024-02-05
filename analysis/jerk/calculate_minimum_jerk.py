from sympy import symbols, diff, Eq, solve
import numpy as np

def get_index_a_b(trial_index, left_index, right_index, PreprocessLeverData_folder):
    """
    The function `get_index_a_b` takes in a trial index, left and right indices, and a folder path, and
    returns the index of the maximum value in a specific range of lever data.
    
    :param trial_index: The trial index is the index of the trial for which you want to retrieve the
    lever data. It is used to construct the file name for the lever data file
    :param left_index: The left index is the starting index of the lever data that you want to search
    for the maximum value
    :param right_index: The `right_index` parameter is the index of the rightmost element in the range
    of leverdata that you want to consider
    :param PreprocessLeverData_folder: The `PreprocessLeverData_folder` parameter is a string that
    represents the folder path where the lever data files are stored. It is used to construct the file
    path for the lever data file that corresponds to the given `trial_index`
    :return: the values of index_a and index_b.
    """
    left_index = int(left_index)
    right_index = int(right_index)
    index_a = left_index

    leverdata = np.fromfile(PreprocessLeverData_folder+"processed_trial"+str(trial_index)+".bin", dtype=np.double)
    index_b = np.argmax(leverdata[left_index:right_index+1]) +left_index

    return index_a, index_b

def get_boundary_conditions(index_a, index_b, trial_index, PreprocessLeverData_folder, Jerk_folder):
    """
    The function `get_boundary_conditions` retrieves the boundary conditions (position, velocity,
    acceleration) and the time duration for a given trial from preprocessed lever data and jerk data.
    
    :param index_a: The index of the starting point in the lever data, velocity, and acceleration arrays
    :param index_b: The parameter "index_b" represents the index of the lever data, velocity, and
    acceleration arrays where the final boundary condition is located. It is used to extract the final
    position, velocity, and acceleration values from the arrays
    :param trial_index: The trial index is an identifier for a specific trial or experiment. It is used
    to load the corresponding data files for that trial
    :param PreprocessLeverData_folder: The folder where the processed lever data files are stored
    :param Jerk_folder: The `Jerk_folder` parameter is the folder path where the jerk data files are
    stored
    :return: the initial and final positions, velocities, accelerations, and the time duration of a
    trial.
    """
    leverdata = np.fromfile(PreprocessLeverData_folder+"processed_trial"+str(trial_index)+".bin", dtype=np.double)
    velocity = np.load(Jerk_folder+"velocity_trial"+str(trial_index)+".npy")
    acceleration = np.load(Jerk_folder+"acceleration_trial"+str(trial_index)+".npy")

    x_0 = leverdata[index_a]
    v_0 = velocity[index_a+1]
    a_0 = acceleration[index_a+2]

    x_f = leverdata[index_b]
    v_f = velocity[index_b+1]
    a_f = acceleration[index_b+2]
    # print("x_0:", x_0, "v_0:", v_0, "a_0:", a_0, "x_f:", x_f, "v_f:", v_f, "a_f:", a_f)

    sample_times = np.fromfile(PreprocessLeverData_folder+"sample_times_trial"+str(trial_index)+".bin", dtype=np.double)
    tf = sample_times[index_b] - sample_times[index_a]
    # print("tf:", tf, "s")

    return x_0, v_0, a_0, x_f, v_f, a_f, tf

def solve_x_coefficients(x_0, v_0, a_0, x_f, v_f, a_f, tf):
    """
    The function `solve_x_coefficients` solves a system of equations to find the coefficients of a
    polynomial function that represents the position of an object over time, given initial and final
    position, velocity, acceleration, and time.
    
    :param x_0: The initial position of the object
    :param v_0: The parameter `v_0` represents the initial velocity
    :param a_0: The parameter `a_0` represents the initial acceleration
    :param x_f: The parameter `x_f` represents the final position of the object
    :param v_f: The parameter `v_f` represents the final velocity
    :param a_f: The parameter `a_f` represents the final acceleration
    :param tf: The parameter "tf" represents the final time. It is the time at which the position,
    velocity, and acceleration values are specified (x_f, v_f, a_f)
    :return: The function `solve_x_coefficients` returns a list of the smoothest x coefficients that
    satisfy the given initial and final conditions.
    """
    # Define the symbols
    t, C1, C2, C3, C4, C5, C6 = symbols('t C1 C2 C3 C4 C5 C6')

    # Define the expression for x(t)
    x_t = C1 * t**5 + C2 * t**4 + C3 * t**3 + C4 * t**2 + C5 * t + C6

    # Define expressions for v(t) and a(t)
    v_t = diff(x_t, t)
    a_t = diff(v_t, t)

    # Set up the system of equations
    equations = [
        Eq(x_t.subs(t, 0), x_0),
        Eq(v_t.subs(t, 0), v_0),
        Eq(a_t.subs(t, 0), a_0),
        Eq(x_t.subs(t, tf), x_f),
        Eq(v_t.subs(t, tf), v_f),
        Eq(a_t.subs(t, tf), a_f)
    ]

    # Solve the system of equations
    solution = solve(equations, (C1, C2, C3, C4, C5, C6))

    # Display the solution
    # print("Solution for the coefficients:")
    smoothest_x_coefficients = []
    for coefficient in [C1, C2, C3, C4, C5, C6]:
        if coefficient in solution:
            smoothest_x_coefficients.append(solution[coefficient])
        else:
            smoothest_x_coefficients.append(0)

    return smoothest_x_coefficients


def solve_x_coefficients_linearalg(x_0, v_0, a_0, x_f, v_f, a_f, tf):
    """
    Not currently used.
    """
    # Setup the system of equations Ax = b
    A = np.array([[1, 0, 0, 0, 0, 0],
                [0, 1, 0, 0, 0, 0],
                [0, 0, 2, 0, 0, 0],
                [1, tf, tf**2, tf**3, tf**4, tf**5],
                [0, 1, 2*tf, 3*tf**2, 4*tf**3, 5*tf**4],
                [0, 0, 2, 6*tf, 12*tf**2, 20*tf**3]])

    b = np.array([x_0, v_0, a_0, x_f, v_f, a_f])

    # Solve for the coefficients
    coefficients = np.linalg.solve(A, b)

    # Output the polynomial coefficients
    # print("The coefficients of the minimum jerk trajectory polynomial are:", coefficients)
    smoothest_x_coefficients = np.flip(coefficients)

    return smoothest_x_coefficients


def smoothest_x_function(smoothest_x_coefficients, t_input):
    """
    The function smoothest_x_function calculates the value of a polynomial function with coefficients
    given by smoothest_x_coefficients at a given input t_input.
    
    :param smoothest_x_coefficients: The smoothest_x_coefficients parameter is a list of 6 coefficients
    [C1, C2, C3, C4, C5, C6] that are used in the calculation of the smoothest_x_function
    :param t_input: The t_input parameter represents the input value for the function. It is the
    independent variable that you want to evaluate the function at
    :return: the value of the polynomial function defined by the smoothest_x_coefficients at the given
    t_input.
    """
    C1 = smoothest_x_coefficients[0]
    C2 = smoothest_x_coefficients[1]
    C3 = smoothest_x_coefficients[2]
    C4 = smoothest_x_coefficients[3]
    C5 = smoothest_x_coefficients[4]
    C6 = smoothest_x_coefficients[5]

    return (C1 * t_input**5 + C2 * t_input**4 + C3 * t_input**3 + C4 * t_input**2 + C5 * t_input + C6)


def minimum_jerk_function_grad(smoothest_x, t_input):
    """
    Not currently used.
    """
    dt = np.median(np.diff(t_input))

    velocity = np.gradient(smoothest_x, dt)

    # Calculate acceleration using central differences
    acceleration = np.gradient(velocity, dt)
   
    # Calculate jerk using central differences
    jerk = np.gradient(acceleration, dt)

    return jerk


def minimum_jerk_function(smoothest_x_coefficients, t_input):
    """
    The function calculates the minimum jerk trajectory from the smoothest position equation.
    
    :param smoothest_x_coefficients: The smoothest_x_coefficients parameter is a list of three
    coefficients [C1, C2, C3] that determine the shape of the smoothest position function.
    :param t_input: The parameter `t_input` represents the time input.
    :return: the value of the minimum jerk function at a given time input.
    """
    C1 = smoothest_x_coefficients[0]
    C2 = smoothest_x_coefficients[1]
    C3 = smoothest_x_coefficients[2]

    return (5*4*3*C1 * t_input**2 + 4*3*2*C2 * t_input + 3*2*C3)