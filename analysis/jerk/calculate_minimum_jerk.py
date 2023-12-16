from sympy import symbols, diff, Eq, solve
import numpy as np

def solve_x_coefficients(x_0, v_0, a_0, x_f, v_f, a_f, tf):
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
    print("Solution for the coefficients:")
    smoothest_x_coefficients = []
    for coeff, value in solution.items():
        print(f"{coeff}: {value}")
        smoothest_x_coefficients.append(value)

    return smoothest_x_coefficients


def solve_x_coefficients_linearalg(x_0, v_0, a_0, x_f, v_f, a_f, tf):
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
    print("The coefficients of the minimum jerk trajectory polynomial are:", coefficients)
    smoothest_x_coefficients = np.flip(coefficients)

    return smoothest_x_coefficients



def smoothest_x_function(smoothest_x_coefficients, t_input):
    C1 = smoothest_x_coefficients[0]
    C2 = smoothest_x_coefficients[1]
    C3 = smoothest_x_coefficients[2]
    C4 = smoothest_x_coefficients[3]
    C5 = smoothest_x_coefficients[4]
    C6 = smoothest_x_coefficients[5]

    return (C1 * t_input**5 + C2 * t_input**4 + C3 * t_input**3 + C4 * t_input**2 + C5 * t_input + C6)

def minimum_jerk_function(smoothest_x, t_input):
    dt = np.median(np.diff(t_input))

    velocity = np.gradient(smoothest_x, dt)

    # Calculate acceleration using central differences
    acceleration = np.gradient(velocity, dt)
   
    # Calculate jerk using central differences
    jerk = np.gradient(acceleration, dt)

    return jerk
