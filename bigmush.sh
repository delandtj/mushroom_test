#!/usr/bin/bash
#
NATNET=172.16.0.0/16
NUMOFNS=250
alias IPN='sudo ip net'
alias IPL='sudo ip link'
alias IPA='sudo ip addr add'

name=""
function IPNA() {
	local name=$1
	shift
	sudo ip -n ${name} addr add $@
}
function IPNL() {
	local name=$1
	shift
	sudo ip -n ${name} link $@
}
function IPNR() {
	local name=$1
	shift
	local defrtr=${1/\/24/}
	shift
	sudo ip -n ${name} route add default via ${defrtr}
}
function createns() {
	local iname=$1
	local in_ip=$2
	local out_ip=$3
	local name=n-${iname}
	IPN add $name
	IPL add in_${iname} type veth peer name out_${iname}
	IPL set in_${iname} netns ${name}
	IPNL ${name} set lo up
	IPNL ${name} set in_${iname} up
	IPL set out_${iname} up
	IPNA ${name} ${in_ip} dev in_${iname}
	IPA ${out_ip} dev out_${iname}
	IPNR ${name} ${out_ip}
	# start mycelium, relying on local discovery
	nohup sudo ip netns exec ${name} mycelium --key-file ${name}.bin --api-addr ${in_ip/\/24/}:8989 --peers ${out_ip/\/24/}:9651 >${iname}.out &
}
function dropns() {
	local iname=$1
	local name=n-${iname}
	IPL del out_${iname}
	IPN del ${name}
}

function doit() {
	nohup sudo mycelium --key-file host.bin --api-addr 127.0.0.1:8989 >host.out &
	for i in $(seq 1 $NUMOFNS); do
		createns ${i} 172.16.${i}.2/24 172.16.${i}.1/24
	done
}
function dropit() {
	sudo pkill -9 mycelium
	for i in $(seq 1 $NUMOFNS); do
		dropns ${i}
	done
}

function cleanit() {
	dropit
	sudo rm ./*.bin
	sudo rm ./*.out
}

function showit() {
	sudo killall -USR1 mycelium
}
