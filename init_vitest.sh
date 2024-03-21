#!/bin/bash

# uncomment the following line to enable debugging
# set -x

# Variables
tests_dir="__tests__"
package_file="package.json"
test_script='"test": "vitest",'
next_config_file=""
config_file=""
setup_file=""
delay=0.5

if [ -z "$1" ]; then
    echo "❌ Error: <path-to-your-project> argument missing."
    echo "Usage: $0 <path-to-your-project>"
    exit 1
fi

dir=$1

if [ ! -d "$dir" ]; then
    echo "❌ The provided directory does not exist."
    exit 1
fi

cd $dir || exit

if [ -f "tsconfig.json" ]; then
    echo "TypeScript configuration detected."
    next_config_file="next.config.mjs"
    config_file="vitest.config.mts"
    setup_file="__tests__/setup.ts"
else
    next_config_file="next.config.mjs"
    config_file="vitest.config.mjs"
    setup_file="__tests__/setup.js"
fi


if [ ! -f $next_config_file ]; then
    echo "❌ The provided directory does not appear to be a Nextjs project (no $next_config_file file found)."
    exit 1
fi

declare -A e2e_pkg_map=( [1]="cypress" [2]="playwright" )

while true; do
    read -p "Which E2E testing package do you want to use? (1-Cypress | 2-Playwright) " e2e_pkg
    echo
    if [[ ${e2e_pkg_map[$e2e_pkg]} == "cypress" ]]
    then
        echo "📦 Installing Cypress..."
        if ! npm install -D cypress; then
            echo "❌ Failed to install Cypress."
            exit 1
        fi
        break
    elif [[ ${e2e_pkg_map[$e2e_pkg]} == "playwright" ]]
    then
        echo "📦 Installing Playwright..."
        if ! npm init playwright@latest; then
            echo "❌ Failed to install Playwright."
            exit 1
        fi
        break
    else
        echo "Invalid input. Please enter '1' for Cypress or '2' for Playwright."
    fi
done

packages="vitest jsdom @vitejs/plugin-react @testing-library/react @testing-library/jest-dom @testing-library/user-event msw@latest"

echo
echo "📦 Installing the packages..."
if ! npm install -D $packages; then
    echo "❌ Failed to install packages."
    exit 1
fi
echo
echo "🔍 Checking if the '$tests_dir' directory exists..."
if [ ! -d $tests_dir ]; then
    echo "📁 Creating the '$tests_dir' directory..."
    mkdir $tests_dir
else
    echo "✅ '$tests_dir' directory already exists."
fi
sleep $delay

echo
echo "🔍 Checking if the '$config_file' file exists..."
if [ ! -f $config_file ]; then
    echo "📄 Creating the '$config_file' file..."
    cat << EOF > $config_file
/// <reference types="vitest" />

import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [react()],
    test: {
        environment: "jsdom",
        globals: true,
        setupFiles: "./$setup_file",
    },
});
EOF
else
    echo "✅ '$config_file' file already exists."
fi
sleep $delay

echo
echo "🔍 Checking if the '$setup_file' file exists..."
if [ ! -f $setup_file ]; then
    echo "📄 Creating the '$setup_file' file..."
    cat << EOF > $setup_file
import { afterEach } from "vitest";
import { cleanup } from "@testing-library/react";
import "@testing-library/jest-dom/vitest";

// runs a clean after each test case (e.g. clearing jsdom)
afterEach(() => {
    cleanup();
});
EOF
else
    echo "✅ '$setup_file' file already exists."
fi
sleep $delay

echo
echo "📝 Adding test script to $package_file..."
if sed -n '/"scripts": {/,/}/{p}' $package_file | grep -q "vitest"; then
    echo "✅ Test script already exists in $package_file"
else
    sed -i "/\"scripts\": {/a \    $test_script" $package_file
    echo "✅ Test script added to $package_file"
fi
sleep $delay

echo
echo "🎉 Script completed successfully."