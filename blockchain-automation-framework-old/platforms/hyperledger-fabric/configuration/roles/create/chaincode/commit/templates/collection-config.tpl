[
{% for collectionconfig in collectionconfigs %}
{% if collectionconfig.channel_name == channel_name %}
  {
    "name": "{{ collectionconfig.name }}",
    "policy": "{{ collectionconfig.policy }}",
    "requiredPeerCount": 0,
    "maxPeerCount": 0,
    "blockToLive": 0
{% if loop.last %}
  }
{% else %}
  },
{% endif %}
{% endif %}
{% endfor %}
]

