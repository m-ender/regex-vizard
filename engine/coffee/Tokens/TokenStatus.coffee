root = global ? window

# Use string primitives instead of objects, so that these cannot be cloned
# (which would break object identity checks)
root.Inactive = "inactive"
root.Active = "active"
root.Matched = "matched"
root.Failed = "failed"
