# Getting Started

A plain-language guide to running this demo yourself, start to finish. No prior
experience with virtual machines or Linux is assumed. If a term is new, it's
explained the first time it appears.

Plan on **about 1 to 1.5 hours** the first time, most of it waiting for
downloads and the install.

## What you're about to do

You'll build a **virtual machine** (VM): a whole computer that runs as a window
on your real PC. You'll install Linux on it, turn on two security features that
real computers have, and then test them:

- **Secure Boot** makes the computer refuse to start or load any code that isn't
  digitally signed by someone it trusts. Think of it as a line of guards, each
  checking the ID of the next person before letting them in.
- A **TPM** (Trusted Platform Module) is a small security chip that writes down
  a fingerprint of everything that ran while the computer started up. Those
  records can't be erased until the next restart.

Then you'll try to sneak a small piece of unsigned code into the system, once
with Secure Boot on (it gets blocked) and once with it off (it gets in, and the
TPM notices that something changed).

Everything happens inside the VM. Nothing you do here changes your real PC's
security settings, except one optional fix in the troubleshooting section that
is clearly marked.

## Before you start: what you need

- **A Windows 10 or 11 PC** that you control (work-managed PCs often block this
  kind of software).
- **At least 8 GB of RAM.** The VM borrows 4 GB while it runs and gives it back
  when it's off.
- **About 30 GB of free disk space.**
- **A stable internet connection** (you'll download about 3 GB).

## Step 1: Install VirtualBox

VirtualBox is free software that runs virtual machines.

1. Go to <https://www.virtualbox.org/wiki/Downloads> and download
   **"Windows hosts."**
2. Run the installer and accept the default options. If Windows asks whether to
   install device software or warns that your network will briefly disconnect,
   click **Yes / Install**.
3. Open **VirtualBox** from the Start menu to make sure it launches.

## Step 2: Download Ubuntu Server

Ubuntu is a free version of Linux. The "Server" edition has no desktop, which
makes it small and fast, and you'll control it by typing commands.

1. Go to <https://ubuntu.com/download/server> and download **Ubuntu Server 24.04
   LTS**. ("LTS" means long-term support.)
2. You'll get a single large file ending in **`.iso`** (about 2.7 GB). An ISO is
   a disk image, like a virtual installation DVD. Leave it in your Downloads
   folder.

## Step 3: Create the virtual machine

1. In VirtualBox, click **New**.
2. Fill in the first screen:
   - **Name:** `SecureBootDemo`
   - **ISO Image:** click the box, choose **Other...**, and pick the Ubuntu
     `.iso` file you downloaded.
   - **Type / Version** should fill in automatically as **Linux / Ubuntu (64-bit)**.
   - Tick **Skip Unattended Installation**. (This lets you see and answer the
     installer's questions yourself, which makes the next steps predictable.)
3. **Hardware:**
   - **Base Memory:** `4096 MB`
   - **Processors:** `2`
   - Tick **Enable EFI**. This is important: EFI is the modern startup firmware,
     and Secure Boot only exists in EFI mode.
4. **Hard Disk:** keep **Create a Virtual Hard Disk Now** at `25 GB`.
5. Click **Finish**. Don't start the VM yet.

## Step 4: Turn on Secure Boot and the TPM

1. Select **SecureBootDemo** in the list and click **Settings**.
2. Go to **System > Motherboard**:
   - Set **TPM** to **v2.0**.
   - Make sure **Enable Secure Boot** is ticked. If VirtualBox asks whether to
     enroll the default keys, click **Yes**.
3. Click **OK**.

The VM now has the same startup protections as a modern laptop.

## Step 5: Set up a way to connect from Windows

You'll type commands into the VM from **Windows Terminal**, because it lets you
copy and paste (the VM's own window doesn't). For that, the VM needs a "door"
your PC can reach.

1. Open **Settings** again and go to **Network > Adapter 1**. It should say
   **Attached to: NAT** (the default).
2. Expand **Advanced** (if needed) and click **Port Forwarding**.
3. Click the **+** icon on the right and fill in the new row:

   | Name | Protocol | Host IP | Host Port | Guest IP | Guest Port |
   |------|----------|---------|-----------|----------|------------|
   | ssh  | TCP      | 127.0.0.1 | 2222    | *(leave blank)* | 22 |

4. Click **OK**, then **OK** again.

In plain terms: anything your PC sends to its own port 2222 gets passed to the
VM's remote-login service.

## Step 6: Install Ubuntu

1. Select **SecureBootDemo** and click **Start**. A window opens and the VM boots
   from the ISO.
2. Pick **Try or Install Ubuntu Server** and press **Enter**. Wait a minute or two.
3. The installer is keyboard-only: use the **arrow keys** and **Tab** to move,
   **Space** to tick a box, and **Enter** to continue. Answer the screens like
   this:
   - **Language:** English. **Keyboard:** your layout. **Installer update:**
     "Continue without updating" is fine.
   - **Type of install:** Ubuntu Server (the default).
   - **Network, Proxy, Mirror:** leave the defaults and press **Done**.
   - **Storage:** keep **Use an entire disk** and press **Done**, then
     **Continue** to confirm. (This only erases the VM's empty virtual disk, not
     your real one.)
   - **Profile:** choose your name, server name `securebootdemo`, username
     `demo`, and a password you'll remember. **Write the password down**; you'll
     need it often.
   - **Ubuntu Pro:** Skip.
   - **SSH:** tick **Install OpenSSH server** (press Space). This is the
     remote-login service from Step 5.
   - **Featured snaps:** don't tick anything; press **Done**.
4. Wait for the install to finish (10 to 20 minutes), then choose **Reboot Now**.
   If it says to remove the installation medium, just press **Enter**.
5. When you see a `securebootdemo login:` prompt, the VM is ready. You can
   minimize its window.

## Step 7: Connect from Windows Terminal

1. Open **Windows Terminal** (or **Command Prompt**) from the Start menu.
2. Type this and press **Enter**:

   ```
   ssh -p 2222 demo@127.0.0.1
   ```

3. The first time, it asks whether you trust this computer. Type `yes` and press
   **Enter**.
4. Type your VM password. **Nothing appears while you type;** that's normal.
   Press **Enter**.

You're in when the prompt looks like `demo@securebootdemo:~$`. Every command from
here on goes into this window.

> **Tip:** to paste in Windows Terminal, right-click or press **Ctrl + V**.

## Step 8: Install the demo tools

1. Open [`setup.sh`](setup.sh) from this project, select everything, and copy it.
2. Paste it into the terminal and press **Enter**.
3. When it asks for your password (`[sudo] password for demo`), type the VM
   password. `sudo` means "run this as administrator."
4. Wait a few minutes. It installs three tools and builds a tiny test program
   called a **kernel module** (code that runs inside the core of the operating
   system, the same place a rootkit would hide). The module is deliberately
   **not signed**.

You'll know it worked when the last lines say `Setup done. hello.ko built
(unsigned):` followed by a file listing.

## Step 9: Run the demo with Secure Boot ON

Go into the demo folder first. **Every command below needs this,** and you need
to do it again each time you reconnect:

```
cd ~/demo
```

Your prompt should now end in `~/demo$`.

**Scene 1: Is Secure Boot on?**

```
mokutil --sb-state
```

You should see `SecureBoot enabled`. The VM started through a chain of signed,
checked steps.

**Scene 2: Try to load unsigned code**

```
sudo insmod hello.ko
```

You should see `ERROR: could not insert module hello.ko: Key was rejected by
service`. The kernel refused the unsigned module. This is the blocking you want.

**Scene 3: Read the TPM's boot fingerprints**

```
sudo tpm2_pcrread sha256:0,7 | tee pcr-on.txt
```

You'll see two long codes. **PCR 0** is the fingerprint of the firmware, and
**PCR 7** is the fingerprint of the Secure Boot settings. The command also saves
them to a file called `pcr-on.txt` so you can compare later.

**Scene 4: Memory randomization**

```
grep stack /proc/self/maps
grep stack /proc/self/maps
```

The two addresses at the start of each line are different. Programs land in a
random spot in memory every time, so an attacker can't predict where to aim.

When you're done, shut the VM down:

```
sudo poweroff
```

## Step 10: Turn Secure Boot OFF and run it again

1. In VirtualBox, wait until **SecureBootDemo** shows **Powered Off**.
2. Open **Settings > System > Motherboard**, **untick Enable Secure Boot**, and
   click **OK**.
3. Click **Start**, wait for the login prompt, and reconnect from Windows
   Terminal with the same `ssh` command from Step 7.
4. Go back into the demo folder:

   ```
   cd ~/demo
   ```

**Scene 5: The TPM notices the change**

```
mokutil --sb-state
sudo tpm2_pcrread sha256:0,7 | tee pcr-off.txt
diff pcr-on.txt pcr-off.txt
```

You should see `SecureBoot disabled`, and `diff` (which shows only the lines that
differ between two files) lists **PCR 7** with an old value (`<`) and a new value
(`>`). PCR 0 isn't listed, because the firmware itself didn't change. The TPM
caught the change in the startup settings. A system that ties its disk key to
these fingerprints would now refuse to unlock.

**Scene 6: Now the unsigned code gets in**

```
sudo insmod hello.ko
sudo dmesg | tail -3
sudo rmmod hello
```

This time there's no error. `dmesg` (the kernel's message log) shows
`module verification failed ... tainting kernel` and `hello: UNSIGNED module
loaded into the kernel`. Without Secure Boot, the same code walks right in.
`rmmod` removes it again.

## Step 11: Put things back

1. Shut down with `sudo poweroff`.
2. In **Settings > System > Motherboard**, tick **Enable Secure Boot** again.

To delete the VM entirely when you're finished, right-click it in VirtualBox and
choose **Remove... > Delete all files**.

## If something goes wrong

**The install freezes at "Loading essential drivers," or VirtualBox is very slow
(a green turtle icon in the corner of the VM window).**
Windows' own virtualization layer (Hyper-V) is in the way. This happens on many
Windows 11 PCs, especially ones with Docker Desktop or WSL2 installed. To fix it:
1. Open **Windows Security > Device security > Core isolation details** and turn
   **Memory integrity** off.
2. Open **Command Prompt as administrator** and run:
   `bcdedit /set hypervisorlaunchtype off`
3. Restart your PC and try again.

To undo this later (Docker Desktop and WSL2 need it), run
`bcdedit /set hypervisorlaunchtype auto` as administrator, restart, and turn
Memory integrity back on. *This is the one step in this guide that changes your
real PC's settings.*

**`mokutil` says `SecureBoot disabled` even though the box is ticked.**
Shut the VM down, open **Settings > System > Motherboard**, click **Reset Keys to
Default**, and start it again.

**`insmod: ERROR: could not load module hello.ko: No such file or directory`.**
You're not in the demo folder. Run `cd ~/demo` and try again.

**`ssh: connect to host 127.0.0.1 port 2222: Connection refused`.**
The VM is still starting (wait 30 seconds), the port-forwarding rule from Step 5
is missing, or OpenSSH wasn't ticked during the install. To add it afterward,
log in on the VM's own window and run `sudo apt install -y openssh-server`.

**`WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!`**
This appears if you rebuilt the VM. Run `ssh-keygen -R "[127.0.0.1]:2222"` in
Windows Terminal, then connect again.

**`tpm2_pcrread` fails or can't find a TPM.**
The TPM isn't turned on. Shut down the VM and set **TPM** to **v2.0** in
**Settings > System > Motherboard**.

## Recording the demo

On Windows, **Win + Alt + R** starts and stops a screen recording with Xbox Game
Bar, and **Clipchamp** (built in) is enough to trim the clips together. Record
Step 9 and Step 10 as two separate clips, then put them back to back.
