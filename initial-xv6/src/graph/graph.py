import numpy as np
import matplotlib.pyplot as plt

# Define your data
X = ['RR', 'FCFS', "MLFQ"]
rtime = [12, 25, 12]
wtime = [150, 114, 125]

# Create an array for the x-axis
X_axis = np.arange(len(X))

# Create a bar chart
plt.bar(X_axis - 0.2, rtime, 0.4, label='rtime')
plt.bar(X_axis + 0.2, wtime, 0.4, label='wtime')

# Customize labels and title
plt.xticks(X_axis, X)
plt.xlabel("Scheduling")
plt.ylabel("Average Ticks")
plt.title("Scheduling Analysis - schedulertest")

# Add a legend
plt.legend()

# Display the plot
plt.show()
