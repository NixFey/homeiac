let
  pi1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINdSjSwH66gyo/Rr3/lahn7DfBuNbx/ETixRjdXqnI6N";
  sbcs = [ pi1 ];
in
{
  "pi1-op-password.age".publicKeys = [ pi1 ];
  "ssid-info.age".publicKeys = sbcs;
  "tandoor-secrets.age".publicKeys = [ pi1 ];
}