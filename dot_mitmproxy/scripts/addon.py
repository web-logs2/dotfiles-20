import os
from mitmproxy import ctx, http, command, flow
import json

addons=[]

class _req:
    def __init__(self, req=None, resp=None):
        self.req = req
        self.resp = resp
        self.matchstr = ()

    def request(self, flow: http.HTTPFlow):
        if self.req is not None:
            self.req(flow)

    def response(self, flow: http.HTTPFlow):
        if self.resp is not None:
            self.resp(flow)


class Match:
    def __init__(self, *matchstrs):
        self.matchstrs = matchstrs

    def _match(self, flow: http.HTTPFlow) -> bool:
        if len(self.matchstrs) == 0:
            return True
        for match in self.matchstrs:
            if match in flow.request.url:
                return True
        return False

    def addRequest(self, func):
        def wrapFunc(flow: http.HTTPFlow):
            if self._match(flow):
                func(flow)
        addons.append(_req(req=wrapFunc))

    def addResponse(self, func):
        def wrapFunc(flow: http.HTTPFlow):
            if self._match(flow):
                func(flow)
        addons.append(_req(resp=wrapFunc))

    def addHeader(self, key, val):
        def func(flow: http.HTTPFlow):
            flow.request.headers[key] = val
            self.addRequest(func)
        return self

    def modifyResp(self, modifyFunc):
        def func(flow: http.HTTPFlow):
            body = json.loads(flow.response.text)
            changedBody = modifyFunc(body)
            if changedBody is not None:
                body = changedBody
            flow.response.text = json.dumps(body)
        self.addResponse(func)
        return self

    def respWithFile(self, path='resp/resp.json'):
        def modifyFunc(body):
            with open(path) as file:
                return json.load(file)
        self.modifyResp(modifyFunc)


def request(flow: http.HTTPFlow):
    # print()
    # print(flow.request.cookies)
    pass


def response(flow: http.HTTPFlow):
    pass


def tmprequest(flow: http.HTTPFlow):
    # flow.request.query["page"] = "33"
    pass

def tmpresponse(flow: http.HTTPFlow):
    if len(flow.response.text)==0:
        return
    body = json.loads(flow.response.text)
    if body.get('semantic') is not None:
        with open('./resp/resp.json') as file:
            body=json.load(file)
            flow.response.text = json.dumps(body)
    


def modifyFunc(body):
    body['data']['afterTestTime'] = 2
    pass


#  Match('/reqNucleicAcidsDays').modifyResp(modifyFunc)
Match('/trafficRouter/cs').addResponse(tmpresponse)