# Setup Keycloak

## Import the existing realm configuration

### STEP 1: Create new realm

![](images/keycloak-config-1.png)

### STEP 2: Import file `quarkus-realm.json`

![](images/keycloak-config-2.png)

### STEP 3: Verify the name `quarkus`of the imported realm

![](images/keycloak-config-3.png)

### STEP 4: Verify the imported realm settings

![](images/keycloak-config-4.png)

## Users and role mappings in existing realm

### STEP 1: Press `view all users`

You should see following users: `admin`, `alice`, `jdoe`

![](images/keycloak-users.png)

### STEP 2: Verify the role mapping

![](images/keycloak-user.png)