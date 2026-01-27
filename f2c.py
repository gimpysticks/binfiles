#!/usr/bin/env python3
"""Convert Fahrenheit to Celsius"""
import sys

def fahrenheit_to_celsius(fahrenheit):
    return (fahrenheit - 32) * 5/9

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: f2c.py <fahrenheit>")
        sys.exit(1)
    
    try:
        fahrenheit = float(sys.argv[1])
        celsius = fahrenheit_to_celsius(fahrenheit)
        print(f"{fahrenheit}°F = {celsius:.2f}°C")
    except ValueError:
        print("Error: Please provide a valid number")
        sys.exit(1)
