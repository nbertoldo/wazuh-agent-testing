#!/bin/bash

set -e

if command -v apt-get &> /dev/null; then
    # Debian/Ubuntu
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B
    add-apt-repository 'deb [arch=amd64] https://pkg.osquery.io/deb deb main'
    apt-get update
    apt-get install -y osquery
elif command -v yum &> /dev/null; then
    # RedHat/CentOS/Amazon/Oracle
    echo "🔐 Importing osquery GPG key..."
    curl -L https://pkg.osquery.io/rpm/GPG | tee /etc/pki/rpm-gpg/RPM-GPG-KEY-osquery

    echo "➕ Adding osquery repository..."
    yum-config-manager --add-repo https://pkg.osquery.io/rpm/osquery-s3-rpm.repo
    yum-config-manager --enable osquery-s3-rpm-repo

    echo "📦 Installing osquery..."
    yum install -y osquery
else
    echo "❌ Unsupported package manager. Please install osquery manually."
    exit 1
fi