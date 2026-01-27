#!/usr/bin/env python3
"""Convert kilometers per hour to miles per hour"""
import sys

def kph_to_mph(kph):
    return kph * 0.621371

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: kph2mph.py <kph>")
        sys.exit(1)
    
    try:
        kph = float(sys.argv[1])
        mph = kph_to_mph(kph)
        print(f"{kph} km/h = {mph:.2f} mph")
    except ValueError:
        print("Error: Please provide a valid number")
        sys.exit(1)
