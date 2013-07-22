root = global ? window

# Use integer primitives instead of objects, so that these cannot be cloned
# (which would break object identity checks)
root.StartGuard = -1
root.EndGuard = 1