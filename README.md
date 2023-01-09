# Generate Certs

Generate certs for local development

- [Getting Started](#getting-started)
- [Generating the Certs](#generating-the-certs)
  - [Generate Certs for localhost](#generate-certs-for-localhost)
  - [Generate Certs for Apps running on your LAN](#generate-certs-for-apps-running-on-your-lan)
- [Installing the Certificate Authority](#installing-the-certificate-authority)
  - [In Chrome](#in-chrome)
  - [In Firefox](#in-firefox)
  - [On Android](#on-android)
- [Run Your App With the Certs](#run-your-app-with-the-certs)

---

## Getting Started

Some experiences will complain if your App isn't run over `https`. To allow for secure Local development (and LAN Apps over IP), follow the below instructions to generate and install certs.

**NOTE**: If you've already generated and added certs for a specific domain or IP, there's no need to generate and add a new cert. Either delete the old one, or reuse it in your new App.

**NOTE**: If you are using an existing cert and want it to be available to Docker, you'll need to symlink it to this directory so that your `docker-compose.yml` file can access it in the `volumes` section. For example:
```sh
# assuming ./ is within the root of your repo
ln -s "${PWD}/../my_certs" ./certs
```
```yml
volumes:
  - "${PWD}/certs:/app_certs"
```

Run `./bin/gen-certs.sh --help` if you want to see the full list of options.

---

## Generating the Certs

### Generate Certs for localhost

- Run `./bin/gen-certs.sh -f "localhost" -d "localhost"`
- This'll create a `certs.localhost` folder with these files:
   ```sh
   /certs.localhost
     localhost.crt
     localhost.key
     localhost-CA.crt
     localhost-CA.key
   ```

You can then copy, move, or rename the generated folder. Wherever the folder ends up, that location will now be referred to as `<CERTS>`.

### Generate Certs for Apps running on your LAN

Creating certs for Apps running on an IP instead of a domain is pretty much the same as above, except you'll use the `-i` flag instead of `-d`, and provide an IP instead of a domain.

Run `./bin/gen-certs.sh -f "lan-apps" -i "192.168.1.337"`

---

## Installing the Certificate Authority

### In Chrome

**Windows**
- Settings > In the top input, filter by `cert` > Click `Security`
- Click on `Manage certificates`
- Go the `Trusted Root Certification Authorities` tab
- Choose `Import`
- Find the `<CERTS>/localhost-CA.crt` file, and add it.

**OSX**
- One-liner: `sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" "./certs.localhost/localhost-CA.crt"`
- One-liner (vhost): `sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" "./certs.app.local/app.local.crt"`
   - Open Spotlight (`CMD + SPACE`), select Keychain, go to System. You should see `localhost (CA)` listed, and with a blue plus icon.
   
If the above doesn't work, follow the manual instructions below.
- In a terminal, run `open certs.localhost`
- Double-click on `localhost-CA.crt`
- An Add Certificates dialog should open.
   - Select `System` in the Keychain dropdown and click Add.
- Double-click `localhost (CA)` under Keychains > System
   - Expand the Trust section
   - Choose `Always Trust` for the `When using this certificate` dropdown. Close the pop-up.

**Linux**
```sh
sudo cp ./certs.localhost/localhost-CA.crt /etc/ca-certificates/trust-source/anchors/
sudo trust extract-compat
```

**NOTE**: If the cert doesn't seem to be working, you may have to restart your Browser. You can try in Incognito first, but generally a Browser restart works. In some rare cases, a system reboot may be required (I've had to do this on OSX).

### In Firefox

- Options > In the top input, filter by `cert` > Click `View Certificates...`
- Go to the `Authorities` tab
- Click on `Import`
- Find the `<CERTS>/localhost-CA.crt` file, and add it.
- Check `Trust this CA to identify websites`.

### On Android

- Copy the CA `.crt` & `.key` to the device
- Go to `Settings` > `Security` > Click on `Install from storage`
- Select the `.crt` file
- Give it a name

---

## Run Your App With the Certs

**Non-VHost**

The non-`-CA` files will be used for the App. When starting the App via Node or Docker, you'll need to set this environment variable:
```sh
`NODE_EXTRA_CA_CERTS="$PWD/<CERTS>/localhost.crt"`
```
- Note that `$PWD` expands to an absolute file path.
- The App automatically determines the `.key` file so long as the `.key` & `.crt` files have the same name.

**With a VHost**

```sh
# Start the Proxy and the App.
# The Proxy should be using your certs.
dc up
```

Then go to something like: `https://app.local:3000/`

