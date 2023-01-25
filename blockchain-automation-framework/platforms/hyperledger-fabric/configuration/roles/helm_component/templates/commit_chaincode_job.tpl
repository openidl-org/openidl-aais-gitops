apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: {{ component_name }}
  namespace: {{ namespace }}
  annotations:
    fluxcd.io/automated: "false"
spec:
  releaseName: {{ component_name }}
  chart:
    git: {{ git_flux_url }}
    ref: {{ git_branch }}
    path: {{ charts_dir }}/commit_chaincode
  values:
    metadata:
      namespace: {{ namespace }}
      images:
        fabrictools: {{ fabrictools_image }}
        alpineutils: {{ alpine_image }}
    peer:
      name: {{ peer_name }}
      address: {{ peer_address }}
      localmspid: {{ name }}MSP
      loglevel: debug
      tlsstatus: true
    vault:
      role: vault-role
      address: {{ vault.url }}
      authpath: {{ network.env.type }}{{ namespace | e }}-auth
      adminsecretprefix: {{ vault.secret_path | default('secret') }}/crypto/peerOrganizations/{{ namespace }}/users/admin
      secretpath: {{ vault.secret_path | default('secret') }}
      orderersecretprefix: {{ vault.secret_path | default('secret') }}/crypto/peerOrganizations/{{ namespace }}/orderer
      serviceaccountname: vault-auth
      imagesecretname: regcred
      tls: false
    orderer:
      address: {{ participant.ordererAddress }}
    chaincode:
      builder: hyperledger/fabric-ccenv:{{ network.version }}
      name: {{ component_chaincode.name | lower | e }}
      version: {{ component_chaincode.version }}
      sequence: {{ component_chaincode.sequence | default('1') }}
      commitarguments: {{ component_chaincode.arguments | quote}}
      endorsementpolicies:  {{ component_chaincode.endorsements | quote }}
{% if component_chaincode.collectionconfig is defined %}
      collectionconfig: |-
{{ collection_config | indent(width=8, first=True) }}
      usecollectionconfig: true
{% else %}
      usecollectionconfig: false
{% endif %}
    channel:
      name: {{ item.channel_name | lower }}
    endorsers:
      creator: {{ namespace }}
      name: {% for name in approvers.name %} {{ name }} {% endfor %} 
      corepeeraddress: {% for address in approvers.corepeerAddress %} {{ address }} {% endfor %}
