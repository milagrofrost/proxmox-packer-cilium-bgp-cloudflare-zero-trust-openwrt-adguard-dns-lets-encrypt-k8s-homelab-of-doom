# 🚑 Claude to the Rescue

My homelab looked fine from a distance. It wasn't. Parts of it had been limping along or flat out not running for a year or more, and in the case of my backups, a lot longer than that.

In November 2026 I pointed [Claude Code](https://claude.com/claude-code) at it with one question: *"what is this IP?"* About 27 hours later, the same session had repaired the Proxmox host, rebuilt a Kubernetes worker that no longer existed, upgraded the cluster from 1.30 to 1.36, and got backups running again.

Claude did the hands-on work over SSH. I answered questions, made the calls, and ran the few commands it was blocked from running. This page is what happened, including what it got wrong.

> ⚠️ **This was written right after the work, not after weeks of stability.** See [Not proven yet](#-not-proven-yet).

## 📊 The numbers

| | |
|---|---|
| Elapsed time | About 27 hours, much of it waiting on backups, disk tests and me |
| The Kubernetes upgrade itself | About 3 hours 15 minutes, 1.30.5 to 1.36.6 |
| Model calls | 396 |
| New tokens | About 2.4 million |
| Tokens re-read from cache | About 163 million |
| Claude Pro plan | 20% of the weekly limit, as of this write-up |

## 🔥 What was actually wrong

| Problem | How long it had been broken |
|---|---|
| Backups of my NFS data and files had stopped, and nothing was scheduled to run them | **Over 3 years** (August 2023) |
| iCloud photo downloads had stopped because the login expired and nobody told me | **Over 3 years** (July 2023) |
| No VM backups existed at all | Unknown, and that's the scary part |
| A worker node was NotReady with about 60 ghost pods assigned to it. Its VM had been deleted weeks later, and I'd forgotten. I told Claude "keep it, I'll revive it" | **9 months** |
| Kubernetes certificates had expired, and nobody noticed until a reboot made the cluster re-read them | About 2.5 weeks |
| Hourly Velero backups were failing, with 421 of the 720 kept runs failed. That lines up with the certificate expiry, but the link is inferred | About 2.5 weeks |
| Kubernetes was on 1.30, seven minor versions behind and out of support | Years of not upgrading |
| Proxmox storage and replication errors from a storage pool that no longer existed | A long time |
| Gmail was rejecting almost all mail from Proxmox, so alerts weren't reaching me anyway | Unknown |

Some problems were doing a nice job of hiding the others:

- A USB drive was resetting because of a driver problem, and it has since failed two long SMART tests. It's a laptop drive I'd plugged in as a temporary fix when I ran out of space. It then became the home for the new VM backups, so it needs to go.
- The host kept dropping off the network. Claude first suspected a crash, but it was an Intel NIC hanging, 175 times in the logs.
- A smart plug was holding the Proxmox host's IP address, because my DHCP range overlapped it.

**The real root problem: nothing was alerting me about any of this.**

## 🛠️ What got done

**Proxmox**
- Cleared the storage and replication errors, and installed 272 package updates.
- Applied a NIC offload workaround and a USB driver fix.
- Set up nightly VM backups, and restored one into an isolated VM to prove it boots.
- Fixed outgoing mail by sending it through Gmail with an app password.

**Kubernetes**
- Renewed the certificates and recovered the control plane.
- Rebuilt the missing worker from the Packer template, then rebalanced pods across the cluster.
- Upgraded in seven steps, one minor version at a time, with the add-ons moving alongside:

| Component | Before | After |
|---|---|---|
| Kubernetes | 1.30.5 | 1.36.6 |
| Cilium | 1.16.1 | 1.20.4 |
| Gateway API | 1.1.0 | 1.6.3 |
| etcd | 3.5.15 | 3.6.8 |
| cert-manager | 1.15.0 | 1.21.3 |
| Velero | 1.14.1 | 1.18.4 |
| cloudflare-operator | 0.10.4 | 0.14.0 |
| cloudflared | 2024.9.1 | 2026.10.7 |

It stopped at 1.36 rather than the newest release, because Cilium and other key add-ons didn't list support for 1.37 yet. The step-by-step details and gotchas are in the [upgrade notes](../3-k8s-setup/upgrade-notes-2026-11.md).

- Pinned apps to their running image digests.
- Replaced the retired Kubernetes Dashboard with Headlamp.
- Removed what I wasn't using or couldn't fix: Argo CD, LibreNMS, `search`, `notwordle` and the OctoPrint proxy. Their old data is still on NFS.

**NFS server**
- Installed 226 pending package updates and a new kernel.
- Nightly app snapshots and database copies are running again, for the first time since 2023.
- iCloud photo downloads are back, running in Kubernetes, with Telegram alerts for expiring logins.

**Monitoring, finally**
- A daily health report covers backups, expiring certificates and logins, nodes and pods, drive health, disk space, the NIC, IP conflicts, app availability and whether alert mail is getting out.
- A second machine alerts me if the report stops running.
- A weekly job compares random backup files against the live copies.

## 💡 Things I found interesting

**It tested its own test script.** I asked whether there was a test plan, and it admitted there wasn't one at that level. It then wrote a before-and-after capture covering routes, BGP, DNS, every LoadBalancer port, TLS and public URLs, and faked failures to see if the compare caught them. It missed two, and Claude checked why rather than assuming: its fake edits had never applied.

**It noticed that stopping the apps would hide problems.** With everything stopped for the upgrade, most checks would have nothing to reach. So it ran a small canary app the whole way through, with a pod on each worker, an NFS mount, a LoadBalancer IP and a gateway.

**`latest` tags were the sneakiest risk.** Moving a pod to another node can silently upgrade it. One app got upgraded this way before Claude spotted the pattern, and moving the rest could have pulled a newer MariaDB onto real data. So it pinned everything to its running digest first.

**Real failover got tested.** It restarted Cilium on the preferred BGP node while sending traffic: 232 requests, 0 failures.

**My backups weren't what I thought.** Velero's 25 warnings per backup turned out to mean it wasn't capturing any of the app data on NFS. I'd been treating it as a full backup.

**Testing the alert found the alert was broken.** The first email test bounced, which revealed Gmail had rejected 19 of Proxmox's last 20 delivery attempts. Later, a re-run caught a quoting bug that would have silently swallowed the "login expiring" warning.

## 🤦 What went wrong

Not trimming this part, because it's the most useful:

- **It rebooted without checking certificate expiry first,** which caused about 20 minutes of outage.
- **kubeadm 1.32 installed `kube-proxy`,** and the dry-run check was too weak to notice. A later check caught it about a minute after install, and traffic didn't drop.
- **Home Assistant's SQLite database came back corrupt** after being stopped. About 91,000 rows were recovered. SQLite on NFS is fragile, and mine had been corrupted at least five times before this.
- **It pushed to this public repo despite a secret-scan hit.** The script didn't stop on the match. It turned out to be a false alarm, but only by luck. Claude flagged it and checked right away.
- **Several confident claims were wrong.** It reported stale pod counts, called something a bug in my repo when my checkout was just one commit behind, said Proxmox email worked when it was bouncing, and misjudged how my old backups worked until it could log in and look. It corrected these once the evidence showed otherwise.
- **One error was never explained.** An app returned HTTP 500 until a second restart fixed it.

## 🛡️ About the guardrails

Claude Code's safety checks blocked some actions, including deleting two old disks and adding a new SSH key to my router, even when I'd approved the overall plan. It gave me the commands and I ran them myself. Mildly annoying, and also exactly what I'd want for something irreversible or long-lasting.

Giving an AI root on your network is a real trust decision, and this could have gone worse. What made it acceptable here was snapshots and tested backups before the risky parts, and the fact that this is a homelab. I wouldn't do it this way on anything that mattered to someone else.

## 🧪 Not proven yet

When this was written:

- The first scheduled overnight run of all the new backups and the health report hadn't happened yet.
- The NIC workaround hadn't been tested under a heavy load.
- The USB drive is still failing and still holds the VM backups. Moving them to the NFS server and retiring that drive is next.
- Both NFS drives are in one Raspberry Pi, so a power or hardware failure could take out the live data and its backup together. There's still no off-site copy of the app data.

## 📝 What I'm taking away

1. **A job that ran once proves nothing.** Check when it last succeeded, and test that the alert reaches you.
2. **"Temporary" lasts for years.** That USB drive is a good example.
3. **Stay on top of upgrades.** Seven versions in one go is a lot of steps to do at once.
4. **You can't back up what you never checked.** I had backups that weren't backing up the thing I cared about.
5. **AI is great at this, and you still need checks that can catch it being wrong.** The most useful thing Claude built was the set of tests that caught its own mistakes.
