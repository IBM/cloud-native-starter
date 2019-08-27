# Prerequisites for Windows 10

The easiest way to setup your Windows 10 machine for this workshop is using [Docker](https://www.docker.com/) and [Windows PowerShell](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/powershell).
We have defined a ```Dockerfile``` that with the needed configuration to setup a Docker image, that contains all tools and the Cloud-Native-Starter project on a **Ubuntu Linux Docker image**.

1. **Install** Docker by following the steps in the [Docker documentation](https://docs.docker.com/docker-for-windows/install/)


2. **Download** the Cloud Native Starter project as a zipfile to you computer and unzip it to a folder.
   https://github.com/IBM/cloud-native-starter

   ![image](images/windows-setup-01.png)

3. **Open** the **Windows PowerShell** as **Administrator**

4. **Navigate** to the folder ```[YOUR FOLDER]/cloud-native-starter/workshop```

5. **Execute** the command ```docker build -t my-workshop-image:v1 .``` to build the Docker image. 

    _Note:_ You can open [Dockerfile](./Dockerfile) in a editor, if you want to get familiar with the setup of the Docker image.

6. **Execute** the command ```docker run -ti  my-workshop-image:v1``` to run the Docker image and that opens directly the Ubuntu **terminal session**.

7. **Navigate** to **cloud native starter** project inside the Docker image
    ```cd usr/cns/cloud-native-starter```

8. **Execute** the ```iks/scripts/check-prerequisites.sh``` to verify the setup.

    ![image](images/windows-setup-02.png)

---

You are ready to go and you can move on to follow the steps in the [prerequisites](00-prerequisites.md).






