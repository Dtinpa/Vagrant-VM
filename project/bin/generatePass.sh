#!/bin/bash

echo -n $(openssl passwd -1 $1) > ../configs/.secret
echo -n $1 > ../configs/.dbpass