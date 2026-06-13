# Remote GPU Bridge — Ubuntu ↔ Windows NVIDIA Machine

> How to use the Windows machine's NVIDIA GPU from the Ubuntu development machine.

---

## Architecture

```
Ubuntu machine (dev, SSH client)
        │
        │ SSH (key auth)
        ▼
Windows machine (NVIDIA GPU, SSH server via OpenSSH or WSL2)
        │
        ├── PyTorch training jobs
        ├── nvidia-smi monitoring
        └── CUDA environment
```

---

## Step 1: Set Up SSH Server on Windows

### Option A: Windows OpenSSH (recommended)

On the Windows machine (PowerShell as Administrator):

```powershell
# Install OpenSSH server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start and enable the service
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic

# Open firewall
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' `
  -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# Verify
Get-Service sshd
```

### Option B: WSL2 with SSH forwarding

If using WSL2 on Windows, set up SSH inside WSL2 and forward the port via Windows.
See the WSL2 SSH setup guide at: https://docs.microsoft.com/en-us/windows/wsl/networking

---

## Step 2: SSH Key Authentication

On the **Ubuntu machine**:

```bash
# Generate an ED25519 key pair (if you don't have one)
ssh-keygen -t ed25519 -C "training-gpu-bridge" -f ~/.ssh/gpu_machine

# Copy the public key to the Windows machine
# Method 1: Manual (paste content of ~/.ssh/gpu_machine.pub into Windows)
cat ~/.ssh/gpu_machine.pub
# → On Windows: create C:\Users\<YourUser>\.ssh\authorized_keys and paste

# Method 2: Via password auth (if enabled temporarily)
ssh-copy-id -i ~/.ssh/gpu_machine.pub <windows_user>@<windows_ip>
```

### SSH config on Ubuntu (`~/.ssh/config`)

```
Host gpu-machine
    HostName <WINDOWS_MACHINE_IP>
    User <WINDOWS_USERNAME>
    IdentityFile ~/.ssh/gpu_machine
    ServerAliveInterval 60
    ServerAliveCountMax 3
    # Optional: port forwarding for TensorBoard or other services
    # LocalForward 6006 localhost:6006
```

Test the connection:

```bash
ssh gpu-machine
# Should connect without password prompt
```

---

## Step 3: Verify CUDA on the Windows Machine

```bash
ssh gpu-machine "nvidia-smi"
# Should show GPU info, CUDA version, driver version
```

Expected output:

```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 560.xx    Driver Version: 560.xx    CUDA Version: 12.x           |
|-------------------------------+----------------------+----------------------+
| GPU  Name          TCC/WDDM  | Bus-Id        Disp.A | Volatile Uncorr. ECC |
|   0  NVIDIA GeForce ...WDDM  | 00000000:...  On     |                  N/A |
+-------------------------------+----------------------+----------------------+
```

---

## Step 4: File Sync Strategy

### rsync (recommended for training scripts)

```bash
# Push training code to Windows machine
rsync -avz --exclude '__pycache__' --exclude '*.pyc' --exclude '.env' \
  tracks/ai-engineer/05-pytorch/ \
  gpu-machine:~/training/pytorch/

# Pull results / checkpoints back
rsync -avz gpu-machine:~/training/pytorch/checkpoints/ \
  tracks/ai-engineer/05-pytorch/checkpoints/
```

### Useful rsync aliases (add to `~/.bashrc`)

```bash
alias gpu-push='rsync -avz --exclude __pycache__ --exclude "*.pyc" --exclude .env'
alias gpu-pull='rsync -avz'
```

### scp (for single files)

```bash
# Push one file
scp tracks/ai-engineer/05-pytorch/train.py gpu-machine:~/training/

# Pull one file
scp gpu-machine:~/training/model.pth ./checkpoints/
```

---

## Step 5: Running Training Jobs Remotely

### Option A: Interactive SSH session + tmux

```bash
ssh gpu-machine

# On Windows machine, start tmux (WSL2) or just run directly:
python train.py --config config.yaml
```

### Option B: One-liner remote execution

```bash
# Run script directly
ssh gpu-machine "cd ~/training && python train.py --epochs 10"
```

### Option C: Background job with output capture

```bash
# Run in background, redirect output
ssh gpu-machine "nohup python ~/training/train.py > ~/training/logs/train.log 2>&1 &"

# Monitor output
ssh gpu-machine "tail -f ~/training/logs/train.log"
```

---

## Step 6: Monitor GPU Remotely

```bash
# One-shot GPU status
ssh gpu-machine "nvidia-smi"

# Live monitoring (refresh every 2 seconds)
watch -n 2 'ssh gpu-machine "nvidia-smi"'

# GPU utilization over time (log to file for later analysis)
ssh gpu-machine "nvidia-smi --query-gpu=timestamp,utilization.gpu,utilization.memory,memory.used,temperature.gpu --format=csv,noheader -l 5" > gpu_log.csv
```

---

## Step 7: VSCode Remote SSH

```bash
# In VSCode: Ctrl+Shift+P → Remote-SSH: Connect to Host → gpu-machine
# This opens a full VSCode window connected to the Windows machine
# You can edit files, run the terminal, use extensions — all remotely
```

Install on the Windows machine (via VSCode remote):
- Python extension
- Pylance
- Jupyter

---

## Troubleshooting

| Problem | Solution |
|---------|---------|
| `Connection refused` | Check Windows OpenSSH service is running: `Get-Service sshd` |
| `Permission denied (publickey)` | Verify `authorized_keys` permissions on Windows: must be owned by the user, not group-writable |
| `nvidia-smi: command not found` | CUDA not in PATH on Windows; add `C:\Program Files\NVIDIA Corporation\NVSMI` to PATH |
| SSH connection drops during training | Add `ServerAliveInterval 60` to `~/.ssh/config` |
| Slow rsync | Add `--compress` flag; check network bandwidth |
| GPU memory error | Reduce batch size; check nothing else is using the GPU (`nvidia-smi`) |

---

## Security Notes

- Never use password auth for the GPU machine — key-only
- Firewall the Windows machine to only accept SSH from the Ubuntu machine's IP
- Never push `.env` or credential files via rsync (use `--exclude .env`)
- The training machine should not be exposed to the public internet
