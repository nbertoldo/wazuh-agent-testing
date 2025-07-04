#!/bin/bash

set -e

if command -v apt-get &> /dev/null; then
    # Debian/Ubuntu
    echo "🔐 Importing osquery GPG key..."
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B

    echo "➕ Adding osquery repository..."
    echo "deb [arch=amd64] https://pkg.osquery.io/deb deb main" > /etc/apt/sources.list.d/osquery.list

    echo "📦 Updating package index and installing osquery..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y osquery

elif command -v yum &> /dev/null || command -v dnf &> /dev/null; then
    # RedHat/CentOS/Amazon/Oracle

    echo "🔐 Importing osquery GPG key..."
    curl -fsSL https://pkg.osquery.io/rpm/GPG -o /etc/pki/rpm-gpg/RPM-GPG-KEY-osquery

    echo "➕ Adding osquery repository..."
    if command -v yum-config-manager &> /dev/null; then
        yum-config-manager --add-repo https://pkg.osquery.io/rpm/osquery-s3-rpm.repo
        yum-config-manager --enable osquery-s3-rpm-repo
    elif command -v dnf &> /dev/null; then
        dnf config-manager --add-repo https://pkg.osquery.io/rpm/osquery-s3-rpm.repo
        dnf config-manager --set-enabled osquery-s3-rpm-repo
    fi

    echo "📦 Installing osquery..."
    yum install -y osquery || dnf install -y osquery

else
    echo "❌ Unsupported package manager. Please install osquery manually."
    exit 1
fi
