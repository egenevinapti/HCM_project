# Introduction to Coding Concepts: Essential Knowledge

To successfully run scripts and understand their purpose, here’s a brief guide to the foundational concepts and skills you should learn.

---

## 1. **What is the Terminal?**
- The terminal (or command line) is a text-based interface used to interact with your computer.
- It allows you to run commands, manage files, and perform tasks without using a graphical interface.
- Examples:
  - `ls`: Lists files in a directory.
  - `cd`: Changes the directory you are working in.
  - `pwd`: Displays the current directory.

### Suggested Learning:
- Basic navigation (`ls`, `cd`, `pwd`, `mkdir`, `rm`).
- Running commands in sequence using `;` or `&&`.
- Note: use ```rm``` with caution - deleting files is permanent and it can delete whole folders/directories

---

## 2. **What is Bash?**
- Bash is a program that lets your computer understand and run the commands you type in the terminal.
- It's often used to write scripts that automate repetitive tasks.
- When a script starts with ```#!/bin/bash```, this is called a shebang (or hashbang), and it tells the system which program (bash) should be used to run the script.
- Bash is also one type of shell (which is why bash scripts end in ```.sh```). A shell is a program that acts as a bridge between you and the computer's operating system, letting you type commands and get things done (like copying files or running programs).
- For example, in contrast, Windows PowerShell is another shell, and it is also a programming language.
---

## 3. **Python Environments and Package Management**
- **Python Environments**: Isolated spaces for running Python projects with specific dependencies.
  - Tools: Conda (used in this script) or Virtualenv.
- **Package Management**: Installing libraries or software for Python.
  - Tools: `pip` (Python's package installer), `conda`.

- Mantis-ml2 is based in python and so needs this environment and package setup.
  
---

## 4. **Git and Version Control**
- Git is a system for tracking changes in code and collaborating with others.
- Cloning a repository (`git clone`) downloads code from a remote server like GitHub.
- This is how we download the mantis-ml2 package from github and how you can store your code while tracking changes over time.

---

## 5. **Writing and Naming Scripts**
- Scripts are text files containing commands executed sequentially.
- Use clear, descriptive names (e.g., `setup_environment.sh`).
- Follow style guidelines:
  - Use comments (`#`) to explain each step.
  - Use consistent naming for variables (e.g., `snake_case`).
  - Keep scripts modular and reusable.

---

## 6. **Common Terminal Errors**
- **Command Not Found**: Check if the software/module is installed.
- **Permission Denied**: Use `chmod +x script.sh` to make a script executable.
- **Environment Not Found**: Ensure the correct environment is activated before running the script.

---

## 7. **Practice and Resources**
- Practice running simple commands in the terminal to build familiarity.
- Explore beginner-friendly resources, such as:
  - [Codecademy: Command Line](https://www.codecademy.com/learn/learn-the-command-line)
  - [Learn Git](https://git-scm.com/doc)


---


# Writing R Scripts: Tips and Tricks

Use RStudio via Apocrita's Ondemand service: 

[https://ondemand.hpc.qmul.ac.uk/pun/sys/dashboard](https://ondemand.hpc.qmul.ac.uk/pun/sys/dashboard/batch_connect/sys/rstudio-2022/session_contexts/new)

RStudio tutorial (skip installation, it is already available on apocrita):

https://www.datacamp.com/tutorial/r-studio-tutorial?utm_source=chatgpt.com 

Here are some useful tips and tricks to help you write efficient and effective R scripts.

---
## Install and load packages

```
# Install package from CRAN with install.packages() function
install.packages("ggplot2")

# Load the package and its functions
library(ggplot2)
```


## Check your working directory (the folder you are loading data from or saving data to)
```getwd()```

Use setwd() to change your working directory:
```setwd("/path/to/your/directory")```

## **Get Help with Functions**
- R provides built-in help documentation for any function or package.
- Use the `help()` function or `?` to access documentation.
  ```r
  help(mean)   # Opens help for the "mean" function
  ?mean        # Shortcut for the same thing

Example for learning about a plotting package:
  ```help(package = "ggplot2")```
  
- Use basic functions to understand the structure and summary of your data:
```
data <- read.csv("data.csv")
head(data)        # Shows the first 6 rows of the dataset
tail(data)        # Shows the last 6 rows of the dataset
str(data)         # Summarizes the structure of the dataset
summary(data)     # Provides summary statistics for each column
```

## Save your work in the R workspace
- Save your workspace (all variables and objects you have currently loaded in R) to a file using:
  
```save.image("my_workspace.RData")```

- Load the workspace later with:
  
```load("my_workspace.RData")```


--- 


# Writing R Scripts: Style Guidelines

Follow these conventions to write clean, readable, and maintainable R scripts.

---

## **File and Script Naming**
- Use lowercase letters and separate words with underscores (`snake_case`) for script names.
  - Example: `data_analysis.R`, `plot_results.R`.
- Use `.R` as the file extension for all R scripts.

---

## **Naming Conventions**
- **Variables and Functions**: Use `snake_case` for readability for variables (used to store data like a gene list) or functions (code that performs a task using your variables)
  - Example: `mean_value`, `calculate_mean`.
- **Constants**: Use `ALL_CAPS` for constants (fixed values in your code that do not change).
  - Example: `MAX_ITERATIONS`.
- **Functions**: Use descriptive names to explain what your functions do.
  - Example: `summarize_data`, `plot_histogram`.
  - Note: R comes with many base functions already and packages also come with functions ready-to-go.

---

## **Code Layout**
- **Indentation**: Use **2 spaces** per indentation level (avoid tabs).
- **Line Length**: If possible, keep lines under **80 characters** for readability.
- **Blank Lines**:
  - Use blank lines to separate logical sections of the code.
  - Leave one blank line before and after function definitions.

---

## **Comments**
- Use comments to explain why a piece of code exists, not just what it does.
- Use `#` for single-line comments.
  
  ```
  # Load your variable
  data_vector <- read.csv("data.csv")

  # Create your function
  calculate_mean <- function(values) {
  mean_value <- sum(values) / length(values)
  return(mean_value)
  }

  # Apply function to your variable, store results in a new variable
  mean_value <- calculate_mean(data_vector)
  ```


## R Console Shortcuts
- Use the up arrow to recall previous commands.
- Press Tab to autocomplete functions or object names.


