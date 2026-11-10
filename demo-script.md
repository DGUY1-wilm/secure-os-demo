# Secure Boot Demo: Recording Script (about 90 seconds)

**All six scenes were tested on this VM and gave exactly the outputs listed below.**

**Before recording:**
1. Open VirtualBox, select **SecureBootDemo**, and click **Start**. Wait about 30 seconds until it shows a login prompt. You can minimize that window.
2. Open **Windows Terminal** and connect to the VM:
   ```
   ssh -i "C:\Resumes\GitHub Projects\secure-os-demo\demo_vm_key" -p 2222 demo@127.0.0.1
   ```
   Keep the quotes: the folder name "GitHub Projects" has a space in it.
   Type `yes` if it asks about the host key (first time only).
3. **Go into the demo folder** (the test module lives here, so the commands fail without this step):
   ```
   cd ~/demo && clear
   ```
   Check that your prompt now ends in **`~/demo$`**, like `demo@securebootdemo:~/demo$`. If it only shows `~$`, you're in the wrong folder.
4. Make the text big with `Ctrl + =` (4–5 times).
5. When a `sudo` command asks for a password, use the one in `vm-login.txt`. Nothing shows while you type; that's normal.

**Record with:** Xbox Game Bar (`Win + Alt + R` to start/stop). Clips save to `Videos\Captures`.
**Note:** Windows' hypervisor is turned off right now so VirtualBox can run. Docker Desktop and WSL2 won't work until you turn it back on after the demo (see the end of this file).

The demo is recorded in **two parts**: Part A with Secure Boot ON, Part B with Secure Boot OFF.

---

## Part A: Secure Boot ON

> **Before you start recording:** make sure your prompt ends in `~/demo$`. If not, run `cd ~/demo && clear`.

### Scene 1: Secure Boot is active (Paper §10, §11)
```bash
mokutil --sb-state
```
Expected: `SecureBoot enabled`

> **Say:** "This system booted through a verified chain of trust. The firmware only ran a bootloader signed with a trusted key, and the bootloader only ran a signed kernel."

### Scene 2: Unsigned code is blocked (Paper §9 rootkits, §11 driver integrity)
```bash
sudo insmod hello.ko
```
Expected: `insmod: ERROR: could not insert module hello.ko: Key was rejected by service`

> **Say:** "Here I try to load my own kernel module, which isn't signed. The kernel refuses it. This is exactly how a rootkit would try to get in, and it's blocked."

### Scene 3: The TPM recorded the boot (Paper §10 measured boot, §11 TPM)
```bash
sudo tpm2_pcrread sha256:0,7 | tee pcr-on.txt
```
Expected: two long hex values (PCR 0 = firmware, PCR 7 = Secure Boot policy).

> **Say:** "Meanwhile, the TPM chip recorded a fingerprint of every boot stage. PCR 7 is the fingerprint of the Secure Boot settings. These values can't be erased until reboot."

### Scene 4: ASLR randomizes memory (Paper §12)
```bash
grep stack /proc/self/maps
grep stack /proc/self/maps
```
Expected: a different stack address each time.

> **Say:** "And memory is randomized. Each program run puts its stack at a different address, so an attacker can't predict where to jump."

**Stop recording. Shut down the VM:** run `sudo poweroff` in the terminal.

---

## Switch Secure Boot OFF (not recorded)
In VirtualBox: select SecureBootDemo, then **Settings > System > Motherboard**, untick **Enable Secure Boot**, and click OK. Start the VM again and reconnect with the same `ssh` command.

**Go into the demo folder again** (every new connection starts in your home folder):
```
cd ~/demo && clear
```
Check that your prompt ends in **`~/demo$`** before you start recording Part B.

---

## Part B: Secure Boot OFF (the "tampered" boot)

### Scene 5: The TPM notices the change (Paper §11 TPM sealing, attestation)
```bash
mokutil --sb-state
sudo tpm2_pcrread sha256:0,7 | tee pcr-off.txt
diff pcr-on.txt pcr-off.txt
```
Expected: `SecureBoot disabled`, and `diff` shows **PCR 7 changed** while PCR 0 stayed the same.

> **Say:** "Now I've changed the boot configuration, like an attacker would. The TPM's fingerprint for PCR 7 is different. In our design, the disk key is sealed to the original value, so it would stay locked, and remote attestation would alert the regulator."

### Scene 6: Without the chain of trust, the unsigned code gets in
```bash
sudo insmod hello.ko
sudo dmesg | tail -3
sudo rmmod hello
```
Expected: no error; `dmesg` shows `module verification failed ... tainting kernel` and `hello: UNSIGNED module loaded into the kernel`.

> **Say:** "And with Secure Boot off, the same unsigned module loads straight into the kernel. That's why AEGIS-OS treats secure boot as the anchor for everything else."

**Stop recording.** Turn Secure Boot back ON in Settings afterward.

---

## After the demo: turn Windows' hypervisor back on
Only needed if you use Docker Desktop or WSL2. Open **Command Prompt as administrator**, run `bcdedit /set hypervisorlaunchtype auto`, and restart. VirtualBox will be slow again after that. Turn memory integrity back on in Windows Security too, if you want it.

## Editing tip
Put Part A and Part B back to back (Windows **Clipchamp**, built in, works fine), trim the pauses, and aim for 60–90 seconds total. Speed up any typing 2x.
