# repairConnection.sh
This is a script running on my Raspberry PI 3. It checks if my wired Ethernet is established. 
If not, tries to establish a connection. One way of doing this **is to reboot 
the raspy** (it works well at my home).

## Installation

```bash 
sudo cp repairConnection.sh /usr/local/bin/
sudo cp repairConnection.service /etc/systemd/system/

sudo systemctl daemon-reload 
sudo systemctl enable repairConnection.service

# to check the log if needed: 
sudo journalctl -u repairConnection.service -b
```

## Environment
* Raspberry PI 3
* Raspbian
* My home with bad cable
## License
It was created from me and you can do whatever you like. Before using it, 
make sure it makes sense in your environment.