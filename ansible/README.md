# Ansible Playbook Documentation

## Executando um Playbook para um Host Específico

Para executar um playbook em um host específico, utilize o seguinte comando:

```bash
ansible-playbook -i inventory/hosts playbooks/update_upgrade.yml --limit <nome_do_host> -K
```

OBS: A flag `-K` é para requisitar a senha de sudo da máquina