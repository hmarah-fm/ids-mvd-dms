# Fuseki

[Documentation](https://jena.apache.org/documentation/fuseki2/fuseki-config-endpoint.html)

# Endpoints

- for queries
  - ´http://localhost:3032/provider/query´
  - ´http://localhost:3032/consumer/query´

# Troubleshooting

Fuseki stores TDB data in `fuseki/provider/databases` and `fuseki/consumer/databases`, each bind-mounted into its container. The containers run as the `fuseki` user; both startup scripts add the host user's primary group to the container. Each directory must be writable by the host user and group-writable by that group. A setgid directory mode such as `2775` lets new database files inherit the shared group.

For a new local checkout, prepare the directory from the repository root:

```sh
mkdir -p fuseki/provider/databases fuseki/consumer/databases
chmod 2775 fuseki/provider/databases fuseki/consumer/databases
```

If a directory is owned by `root` and is empty, remove only that empty directory and recreate it as your user before applying the mode above. Do not remove a directory containing Fuseki data. Check owners and groups with `stat -c '%A %U:%G %n' fuseki/provider/databases fuseki/consumer/databases` if startup reports a write-permission error.