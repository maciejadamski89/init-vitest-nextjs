# Vitest Setup Script

This script, `init_vitest.sh`, automates the setup of Vitest in a Nextjs project.

## Usage

To use the script, pass the path to your Nextjs project as an argument:

```shell
chmod +x init_vitetest.sh;
./init_vitest.sh /path/to/your/project;
```

## Script steps

-   Change to the provided directory.
-   Check if the directory is a Nextjs project (i.e., it contains a next.config file).
-   Install the necessary packages using npm.
-   Check if the `__tests__` directory exists, and create it if it doesn't.
-   Check if the `vitest.config.ts` file exists, and create it if it doesn't.
-   Check if the `__tests__/setup.ts` file exists, and create it if it doesn't.
-   Add a test script to the `package.json` file.
-   If any of the checks fail, the script will print an error message and exit.

## Requirements

The script must be run in a Unix-like environment with a Bash shell.
The npm command must be available on the system's PATH.
The directory passed to the script must be a valid Node.js project (i.e., it must contain a package.json file).

This README provides a brief overview of what the script does, how to use it, and what the requirements are. It can be expanded with more details if necessary.
