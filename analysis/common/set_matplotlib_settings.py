import matplotlib.pyplot as plt

def set_matplotlib_settings():
    """
    The function sets various settings for matplotlib to customize the appearance of plots.
    :return: nothing (None).
    """
    plt.rcParams['axes.linewidth'] = 2
    plt.rcParams['font.size'] = 14
    plt.rcParams['axes.spines.right'] = False
    plt.rcParams['axes.spines.top'] = False
    plt.rcParams['xtick.major.width'] = 2
    plt.rcParams['ytick.major.width'] = 2
    plt.rcParams['figure.figsize'] = (5, 4)
    plt.rcParams["figure.autolayout"] = True
    return