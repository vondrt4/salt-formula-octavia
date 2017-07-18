octavia:
  manager:
    enabled: true
    version: ocata
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: octavia
      user: octavia
      password: password
    identity:
      engine: keystone
      region: RegionOne
      host: 127.0.0.1
      port: 35357
      user: octavia
      password: password
      tenant: service
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: password
      virtual_host: '/openstack'
    certificates:
      ca_private_key: '/etc/octavia/certs/private/cakey.pem'
      ca_certificate: '/etc/octavia/certs/ca_01.pem'
    controller_worker:
      amp_flavor_id: '967972bb-ab54-4679-9f53-bf81d5e28154'
      amp_image_tag: amphora
      amp_ssh_key_name: octavia_ssh_key
      loadbalancer_topology: 'SINGLE'
    haproxy_amphora:
      client_cert: '/etc/octavia/certs/client.pem'
      client_cert_key: '/etc/octavia/certs/client.key'
      client_cert_all: '/etc/octavia/certs/client_all.pem'
      server_ca: '/etc/octavia/certs/ca_01.pem'
    health_manager:
      bind_ip: 192.168.0.12
      heartbeat_key: 'insecure'
    house_keeping:
      spare_amphora_pool_size: 0
