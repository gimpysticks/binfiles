#!/usr/bin/env python3
import random
import pyperclip

def get_random_item_from_file(filename):
  """Reads a list of items from a file and returns a random item."""

  with open(filename, 'r') as f:
    items = f.read().splitlines()

  return random.choice(items)

# Example usage:
filename = '/home/sticks/Documents/MJ-PCodes'  # Replace with your actual filename
random_item = get_random_item_from_file(filename)
print(random_item)
pyperclip.copy(str(random_item))
print("Random number copied to clipboard.")
