#!/usr/bin/env python3
"""Convert meters to miles"""
import sys

def meters_to_miles(meters):
    return meters * 0.000621371

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: mtrs2miles.py <meters>")
        sys.exit(1)
    
    try:
        meters = float(sys.argv[1])
        miles = meters_to_miles(meters)
        print(f"{meters} m = {miles:.2f} mi")
    except ValueError:
        print("Error: Please provide a valid number")
        sys.exit(1)
