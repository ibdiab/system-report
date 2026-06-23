This is a bash script that gives a report containing various system statistics. For example:
  - Kernel
  - Hostname
  - Running services
  - Ram utilization
  - System uptime
  - And a lot more

# INSTALLATION
1. Download the `sysreport.bash` script from this repo.

2. Navigate to where you downloaded it (ex. `/home/user/Downloads`)

3. Give it executable permissions with `chmod +x sysreport.bash`

4. Run it with ./sysreport.bash
     - Alternatively, you may open the file in your preferred IDE

5. When you run the script, it will make a new folder called `reports` in the same folder you ran the script in, and make a text file with the report. For example:
  - **System Report**
    - sysreport.bash
    - reports
        - _systemreport_2026-06-23_15-26-42.txt_

# EXTRA NOTES - Caution before sharing
- If you share your report with anyone, please remove **EVERYTHING** under the `Network Info` tab **AND YOUR HOSTNAME** for privacy and security
    - There are specific cases in which someone might need some of that information (i.e. debugging network issues, SSH, RDP, etc.). In that case, **ONLY** share what they **NEED**, and **NOTHING** more.
      
- And in general, be careful when sharing this report. **The advice above doesn't apply just for networking, but for everything**. If someone needs something from the file for legit reasons, only give them what they need and nothing more. This ensures that your info stays private to you only, because hackers can use this info (especially networking) to attack your system.
