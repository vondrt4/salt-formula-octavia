{%- from "octavia/map.jinja" import manager with context %}

{%- if manager.enabled %}

{%- set ssh_dir = salt['file.dirname'](manager.ssh.private_key_file) %}

{%- if manager.version not in ["mitaka"] %}
octavia_manager_packages:
  pkg.installed:
  - names: {{ manager.pkgs }}
{%- endif %}

/etc/octavia/octavia_manager.conf:
  file.managed:
  - source: salt://octavia/files/{{ manager.version }}/octavia_manager.conf
  - template: jinja
{%- if manager.version not in ["mitaka"] %}
  - require:
    - pkg: octavia_manager_packages
{%- endif %}

/etc/octavia/certificates/openssl.cnf:
  file.managed:
  - source: salt://octavia/files/{{ manager.version }}/certificates/openssl.cnf
{%- if manager.version not in ["mitaka"] %}
  - require:
    - pkg: octavia_manager_packages
{%- endif %}

{% set dhclient_conf_path = '/etc/octavia/dhcp/dhclient.conf' %}

{{ dhclient_conf_path }}:
  file.managed:
  - source: salt://octavia/files/{{ manager.version }}/dhcp/dhclient.conf
{%- if manager.version not in ["mitaka"] %}
  - require:
    - pkg: octavia_manager_packages
{%- endif %}

octavia_ssh_dir:
  file.directory:
    - name: {{ ssh_dir }}
    - user: {{ manager.ssh.user }}
    - group: {{ manager.ssh.group }}
    - makedirs: true

octavia_ssh_private_key:
  file.managed:
    - name: {{ manager.ssh.private_key_file }}
    - contents_pillar: octavia:manager:ssh:private_key
    - user: {{ manager.ssh.user }}
    - group: {{ manager.ssh.group }}
    - mode: 600
    - require:
      - file: octavia_ssh_dir


{%- if not grains.get('noservices', False) %}

health_manager_ovs_port:
  cmd.run:
  - name: "ovs-vsctl -- --may-exist add-port br-int o-hm0 -- set Interface
  o-hm0 type=internal -- set Interface o-hm0 external-ids:iface-status=active
  -- set Interface o-hm0 external-ids:attached-mac={{
  manager.controller_worker.amp_hm_port_mac }} -- set Interface o-hm0
  external-ids:iface-id={{ manager.controller_worker.amp_hm_port_id }} -- set
  Interface o-hm0 external-ids:skip_cleanup=true"
  - unless: ovs-vsctl show | grep o-hm0

health_manager_port_set_mac:
  cmd.run:
  - name: "ip link set dev o-hm0 address {{
  manager.controller_worker.amp_hm_port_mac }}"
  - unless: "ip link show o-hm0 | grep {{
  manager.controller_worker.amp_hm_port_mac }}"
  - require:
    - cmd: health_manager_ovs_port

health_manager_port_dhclient:
  cmd.run:
  - name: dhclient -v o-hm0 -cf {{ dhclient_conf_path }}
  - require:
    - cmd: health_manager_port_set_mac

{#
health_manager_port_add_rule:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - in-interface: o-hm0
    - dport: 5555
    - proto: udp
    - save: True
#}

octavia_manager_services:
  service.running:
  - names: {{ manager.services }}
  - enable: true
  - watch:
    - file: /etc/octavia/octavia_manager.conf
{%- endif %}

{%- endif %}
