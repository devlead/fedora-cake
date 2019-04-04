
FROM fedora:28
ENV CAKE_VERSION 0.33.0
ENV CAKE_SETTINGS_SKIPVERIFICATION true
ADD cakeprimer cakeprimer
ADD cake /usr/bin/cake


# Install .NET Core and Mono
RUN rpm --import "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" \
	&& curl -s https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo \
    && rpm --import https://packages.microsoft.com/keys/microsoft.asc \
    && curl -s https://packages.microsoft.com/config/fedora/27/prod.repo | tee /etc/yum.repos.d/microsoft-prod.repo \
    && chown root:root /etc/yum.repos.d/microsoft-prod.repo \
    && dnf update -y \
	&& dnf install -y mono-complete dotnet-sdk-2.1 \
	&& dnf clean all  \
    && mkdir -p /opt/nuget \
    && curl -Lsfo /opt/nuget/nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

ENV PATH "$PATH:/opt/nuget"

# Prime dotnet & Cake
RUN mkdir dotnettest \
    && cd dotnettest \
    && dotnet new console -lang C# \
    && dotnet restore \
    && dotnet build \
    && dotnet run \
    && cd .. \
    && rm -r dotnettest \
    && cd cakeprimer \
    && dotnet restore Cake.sln \
    --source "https://www.myget.org/F/xunit/api/v3/index.json" \
    --source "https://api.nuget.org/v3/index.json" \
     /property:UseTargetingPack=true \
    && cd .. \
    && rm -rf cakeprimer

# Install Cake & Test Cake & Display info installed components
RUN mkdir -p /opt/Cake/Cake \
    && curl -Lsfo Cake.zip "https://www.nuget.org/api/v2/package/Cake/$CAKE_VERSION" \
    && unzip -q Cake.zip -d "/opt/Cake/Cake" \
    && rm -f Cake.zip \
    && chmod 755 /usr/bin/cake \
    && sync \
    && mkdir caketest \
    && cd caketest \
    && cake --version \
    && cd .. \
    && rm -rf caketest \
    && mono --version \
    && dotnet --info \