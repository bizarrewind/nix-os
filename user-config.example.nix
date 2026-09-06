# user-config.nix — Machine-specific overrides
# ─────────────────────────────────────────────
# Copy this file to user-config.nix and fill in your values.
# This file is listed in .gitignore and will never be committed.
#
# Run setup.sh for a guided setup:  bash setup.sh
{
  # Your Linux username (what you'd type at the login prompt)
  username = "youruser";

  # Enable keyd keyboard remapping daemon (disabled by default)
  # Set to true if you use keyd or custom key remapping
  enableKeyd = false;
}
