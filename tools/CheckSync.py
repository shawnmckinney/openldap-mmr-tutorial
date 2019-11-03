#!/usr/bin/python

class ServerConfig(object):
    def __init__(self):
        self.uri         = ""
        self.searchbase  = []
        self.binddn      = ""
        self.ca_cert     = ""
        self.server_cert = ""
        self.server_key  = ""
        self.role        = 0  # 0 = Consumer; 1 = Provider; 2 = MMR Provider;
        self.serverid    = 0
        
    def is_bind_simple(self):
        return True if (len(self.binddn) > 0) else False