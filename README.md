# Scripts de Configuração para Wayland e Containers

Este repositório contém scripts para configurar e gerenciar ambientes relacionados ao **Wayland** e containers **LXC/LXD**. Os scripts foram projetados para garantir funcionalidade e facilitar tarefas como configuração do ambiente Wayland, compartilhamento de dispositivos binder e execução de scripts dentro de containers.

---

## Ordem de Execução e Descrição dos Scripts

### 1. `create_container.sh`
**Descrição:** Cria um container LXC/LXD baseado na imagem Ubuntu e inicializa o ambiente básico.

**Execução:**
```bash
sudo ./create_container.sh <nome_do_container>
```

**Entrada:**
- `<nome_do_container>`: Nome do container que será criado.

**Saída:**
- Container configurado e pronto para uso.

---

### 2. `compartilhar_binder.sh`
**Descrição:** Compartilha o sistema de arquivos binder (`/dev/binderfs`) do host com o container.

**Execução:**
```bash
sudo ./compartilhar_binder.sh <nome_do_container>
```

**Entrada:**
- `<nome_do_container>`: Nome do container para o qual o binder será compartilhado.

**Saída:**
- Dispositivos binder acessíveis no container.

---

### 3. `executar_scripts_no_container.sh`
**Descrição:** Copia scripts do host para o container e executa cada um deles, passando o nome do container como argumento.

**Execução:**
```bash
sudo ./executar_scripts_no_container.sh <nome_do_container>
```

**Entrada:**
- `<nome_do_container>`: Nome do container onde os scripts serão executados.

**Saída:**
- Scripts executados dentro do container com o parâmetro `<nome_do_container>`.

---

### 4. `configurar_wayland.sh`
**Descrição:** Verifica dependências do Wayland no host e configura o Wayland no container.

**Execução:**
```bash
sudo ./configurar_wayland.sh <nome_do_container>
```

**Entrada:**
- `<nome_do_container>`: Nome do container onde o Wayland será configurado.

**Saída:**
- Ambiente Wayland configurado para uso no container.

---

## Como Usar os Scripts

1. Certifique-se de que os scripts têm permissão de execução:
  ```bash
  chmod +x *.sh
  ```

2. Execute cada script na ordem listada acima, passando o nome do container como argumento.

3. Verifique as mensagens exibidas pelos scripts para garantir que todas as etapas foram concluídas com sucesso.

---

## Requisitos

- Sistema operacional Linux com suporte ao **LXC/LXD**.
- **Wayland** configurado e funcional no host.
- Dependências instaladas automaticamente pelos scripts, como `wayland-protocols`, `libwayland-dev`, entre outros.

---

## Observações

- Certifique-se de que o módulo `binder_linux` está carregado no host antes de executar o script de compartilhamento do binder.
- Use os scripts em ambientes controlados e assegure-se de que os containers têm permissões adequadas para acessar os recursos compartilhados.

---

## Referências

- **Use case:** [https://gist.github.com/stueja/447bd3bc0d510a0a7e50f9f1ef58ad75](https://gist.github.com/stueja/447bd3bc0d510a0a7e50f9f1ef58ad75)
- **Waydroid:** [https://sourceforge.net/projects/waydroid/](https://sourceforge.net/projects/waydroid/)
- **LXD:** [https://documentation.ubuntu.com/server/how-to/containers/lxd-containers/](https://documentation.ubuntu.com/server/how-to/containers/lxd-containers/)
- **Instalação:**  
  - [https://docs.waydro.id/usage/install-on-desktops](https://docs.waydro.id/usage/install-on-desktops)  
  - [https://linuxconfig.org/how-to-enable-disable-wayland-on-ubuntu-22-04-desktop](https://linuxconfig.org/how-to-enable-disable-wayland-on-ubuntu-22-04-desktop)

- **Binder:**  
  - [https://www.reddit.com/r/linux4noobs/comments/rdpsz4/driver_problem_while_attempting_to_install/]