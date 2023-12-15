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


def minimum_jerk(smoothest_x_solution, tf):

    return 
