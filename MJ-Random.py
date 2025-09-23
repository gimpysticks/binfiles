#!/usr/bin/python3
import sys
import random
import pyperclip

def generate_random_number(min_value=1, max_value=4294967295):
  """Generates a random integer between min_value and max_value.

  Args:
    min_value: The minimum value of the random number (default: 1).
    max_value: The maximum value of the random number (default: 4294967295).

  Returns:
    A random integer between min_value and max_value.
  """

  if min_value > max_value:
    raise ValueError("min_value must be less than or equal to max_value")

  return random.randint(min_value, max_value)

if __name__ == "__main__":
  if len(sys.argv) > 1:
    min_value = int(sys.argv[1])
    max_value = int(sys.argv[2])
  else:
    min_value = 1
    max_value = 4294967295

  random_number = generate_random_number(min_value, max_value)
  print("Random number:", random_number)

  pyperclip.copy(str(random_number))
  print("Random number copied to clipboard.")
