{%- from "octavia/map.jinja" import api with context %}

{%- if api.enabled %}

include:
  - octavia.db.offline_sync

{%- if api.version not in ["mitaka"] %}
{# no octavia packages in Ubuntu until 18.10 cosmic #}
octavia_api_packages:
  pkg.installed:
  - names: {{ api.pkgs }}
  - require_in:
    - sls: octavia.db.offline_sync
{%- endif %}

octavia_user:
  user.present:
    - name: octavia
    - home: /var/lib/octavia
#    - uid: 302
#    - gid: 302
    - shell: /bin/false
    - system: True

octavia_group:
  group.present:
    - name: octavia
#    - gid: 302
    - system: True

/etc/octavia:
  file.directory:
  - mode: 755
  - user: octavia
  - group: octavia

/etc/octavia/certificates:
  file.directory:
  - mode: 755
  - user: octavia
  - group: octavia

/etc/octavia/dhcp:
  file.directory:
  - mode: 755
  - user: octavia
  - group: octavia

/etc/octavia/octavia_api.conf:
  file.managed:
  - source: salt://octavia/files/{{ api.version }}/octavia_api.conf
  - template: jinja
{%- if api.version not in ["mitaka"] %}
  - require:
    - pkg: octavia_api_packages
{%- endif %}
  - require_in:
    - sls: octavia.db.offline_sync

{%- if pillar.octavia.manager is not defined %}
/etc/octavia/certificates/openssl.cnf:
  file.managed:
  - source: salt://octavia/files/{{ api.version }}/certificates/openssl.cnf
{%- if api.version not in ["mitaka"] %}
  - require:
    - pkg: octavia_api_packages
{%- endif %}

/etc/octavia/dhcp/dhclient.conf:
  file.managed:
  - source: salt://octavia/files/{{ api.version }}/dhcp/dhclient.conf
{%- if api.version not in ["mitaka"] %}
  - require:
    - pkg: octavia_api_packages
{%- endif %}
{%- endif %}


{%- if not grains.get('noservices', False) %}
octavia_api_services:
  service.running:
  - names: {{ api.services }}
  - enable: true
  - watch:
    - file: /etc/octavia/octavia_api.conf
  - require:
    - sls: octavia.db.offline_sync
{%- endif %}

{%- endif %}
