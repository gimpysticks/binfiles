#!/usr/bin/env python3
import sys

def calculate_speed(distance, time):
    """Calculates speed and handles mathematical/type errors."""
    try:
        d = float(distance)
        t = float(time)
        
        if t <= 0:
            return "Error: Time must be a positive number greater than zero."
        
        speed = d / t
        return f"Calculated Speed: {speed:.2f}"
        
    except ValueError:
        return "Error: Both arguments must be valid numbers."

def main():
    # sys.argv[0] is the script name itself.
    # We check if there are exactly 2 additional arguments (dist and time).
    if len(sys.argv) == 3:
        dist = sys.argv[1]
        time = sys.argv[2]
        print(calculate_speed(dist, time))
    
    # If no arguments are provided, fall back to interactive mode
    elif len(sys.argv) == 1:
        try:
            dist = input("Enter distance: ")
            time = input("Enter time: ")
            print(calculate_speed(dist, time))
        except (KeyboardInterrupt, EOFError):
            print("\nOperation cancelled.")
            sys.exit(0)
            
    # If the user provided the wrong number of arguments
    else:
        print("Usage: ./speed_calc.py [distance] [time]")
        print("Example: ./speed_calc.py 100 2")
        sys.exit(1)

if __name__ == "__main__":
    main()