//
// Model of the network, consisting of serveral servers(the cluster), a client, and a switch that connect them
//
package raft;

import inet.node.ethernet.EthernetSwitch;
import inet.common.scenario.ScenarioManager;
import inet.common.packet.recorder.PcapRecorder;

network Raft
{
    parameters:
        int numServers @prompt("Number of servers") = default(3);
        int numClients @prompt("Number of clients") = default(2);
        int numPcapRecorders @prompt("Number of PCap recorders") = default(1);
        @display("bgb=793,486");
    submodules:
        admin: Admin {
            parameters:
                @display("p=70,40");
        }
        client[numClients]: Client {
            parameters:
                @display("p=210,56,m,10,200");
        }
        pcapRecorder[numPcapRecorders]: PcapRecorder {
            parameters:
                @display("p=147,397");
                pcapFile = "captures/" + expand("${configname}-") + fullPath() + ".pcapng";
                moduleNamePatterns = "switch";
                packetFilter = "*";
                sendingSignalNames = "packetSent";
                receivingSignalNames = "packetReceived";
                dumpProtocols = "ethernetmac unknown ipv4 tcp udp";
        }
        scenarioManager: ScenarioManager {
            @display("p=425,397");
        }
        switch: Switch {
            parameters:
                @display("p=210,170");
            gates:
                port[parent.numServers+parent.numClients+1]; // 1 extra port for the admin
        }
        server[numServers]: Server {
            parameters:
                @display("p=70,270,m,10,320");
        }
    connections:
        admin.port <--> switch.port[0];
        for i=0..numClients-1 {
            client[i].port <--> {  delay = 10ms; } <--> switch.port[i+1];
        }
        for i=0..numServers-1 {
            server[i].port <--> {  delay = 1ms; } <--> switch.port[numClients+1+i];
        }
}
