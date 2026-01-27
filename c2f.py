#!/usr/bin/env python3
"""Convert Celsius to Fahrenheit"""
import sys

def celsius_to_fahrenheit(celsius):
    return (celsius * 9/5) + 32

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: c2f.py <celsius>")
        sys.exit(1)
    
    try:
        celsius = float(sys.argv[1])
        fahrenheit = celsius_to_fahrenheit(celsius)
        print(f"{celsius}°C = {fahrenheit:.2f}°F")
    except ValueError:
        print("Error: Please provide a valid number")
        sys.exit(1)
