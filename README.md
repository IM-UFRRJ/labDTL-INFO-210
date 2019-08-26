# labDTL-INFO-210
Scripts para a a instalação e configuração inicial dos equipamentos do Laboratório do DTL localizado na sala INFO-210.

## Pré-requisitos

- É necessário um computador central como o Ubuntu instalado. O computador deve estar conectado na mesma rede dos computadores alvos, e a internet deve estar acessível pela mesma rede.

## Passos

1) **Fase de Live CDs/USBs:**
   Preparar CDs/pendrives "bootáveis" com a versão do _Ubuntu 18.04 Live Server_. Links úteis:
   - [Download Ubuntu Server](https://ubuntu.com/download/server)
   - [Create a bootable Ubuntu USB on Ubuntu](https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-ubuntu)
   - [Create a bootable Ubuntu USB on Windows](https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-windows)

1) **Fase de Clonagem:**
   Clonar este repositório no computador central.
   ```
   git clone https://github.com/IM-UFRRJ/labDTL-INFO-210.git
   ```

1) **Fase de Preparação:**
   Executar o comando abaixo no computador central. Este comando instala os programas e prepara os serviços necessários às fases seguintes (ex.: ansible e squid proxy). _**IMPORTANTE**: anotar o endereço do proxy exibido durante a execução do script, pois será utilizado na fase posterior._
   ```
   ./00_prepare_services.sh
   ```

1) **Fase de Instalação do SO:**
   Instalar o Sistema Operacional (SO) Ubuntu Live Server em cada um dos computadores alvos através do CD/USB boot, e durante o processo de instalação as considerações abaixo devem **OBRIGATORIAMENTE** ser levadas em conta.
   1) Não é necessário configurar o tipo de teclado (será configurado automaticamente posteriormente).
   1) Nomear cada PC de acordo com o número do patrimônio correspondente, no seguinte formato `123456`.
   1) Configurar o endereço do servidor proxy para poder ter acesso direto à internet, e assim não precisar da autenticação de usuário da rede. _Obs.: O endereço do servidor proxy (o computador central) deveria ter sido anotado na fase anterior, e deve ter este formado: http://<IP_PROXY_SERVER>:3128/_
   1) Configurar o login e senha do usuário administrador, que terá permissão de root. _**IMPORTANTE**: Estas informações devem ser anotadas, e o login recomendado é `admindtl`._
   1) Habilitar o OpenSSH.
   1) Após a finalização da instalação com sucesso, o computador deve ser reiniciado.

1) **Fase de Varredura da Rede:**
   Executar o comando abaixo no computador central. Este comando varre a rede para encontrar PCs com o SSH ativado. No início é preciso indicar qual a interface de rede a ser utilizada, e ao final será criado e exibido o conteúdo de um arquivo contendo a lista de IPs dos PCs localizados. **IMPORTANTE**: a lista de IPs deve ter no mínimo a quantidade de computadores alvos. Caso a lista tenha uma quantidade menor, então algum PC pode estar desconectado ou não ter obtido IP da rede. _Possíveis causas: o cabo de rede pode estar desconectado (deve ser reconectado), ou o relógio da BIOS pode não está correto (deve ser ajustado para +3h da hora local e atual)._
   ```
   ./01_get_hosts.sh
   ```

1) **Fase de Configuração do Acesso via SSH:**
   Executar o comando abaixo no computador central. Este comando cria uma chave de autenticação para acesso remoto via SSH do computador central, e em seguida instala essa chave em cada computador remoto/alvo a partir da lista de IPs obtida na fase anterior. _Obs: Será solicitado a informação de login e senha do usuário administrador já configurado (e anotado) durante a fase de instalão do sistema em cada PC alvo._ Ao final será criado um novo arquivo com a lista de IPs dos PC em que as chaves de SSH foram instaladas com sucesso, e seu conteúdo será exibido. **IMPORTANTE**: a lista de IPs deve ter no exatamente a quantidade de computadores alvos. Caso a lista tenha uma quantidade menor, então algum PC pode estar desconectado ou não ter obtido IP da rede, ou ainda o login/senha estão diferentes no PC ausente da lista (para solucionar este último problema, a fase de instalação do SO deve ser repetida no PC ausente).
   ```
   ./02_set_ssh_keys.sh
   ```

1) **Fase de Teste do Ansible via SSH:**
   Executar o comando abaixo no computador central. Este comando testa o acesso via _ansible_ a cada PC alvo/remoto e configura um apelido aos IPs a partir do nome dado a cada PC durante a fase de instalação do SO. O login do usuário administrador será solicitado. Em seguida será criado novo um arquivo no formato em que o _Ansible_ espera contendo a lista de hosts alvos, e o mesmo será exibido. Novamente, a quantidade de IPs presentes na lista de hosts deve ser verificada.
   ```
   ./03_setting_hosts.sh
   ```

1) **Fase de Habilitação dos _Playbooks_:**
   Executar o comando abaixo no computador central. Este script cria links simbólicos para habilitar todos os arquivos disponíveis de _playbook_ do _ansible_ presentes neste repositório. Após a execução deste, caso seja necessário desconsiderar algum _playbook_ em específico, basta deletar o link simbólico correspondente presente no diretório `playbooks-enabled`.
   ```
   ./links2available.sh
   ```

1) **Fase de Instalção e Configuração dos PCs Alvos/Remotos:**
   Executar o comando abaixo no computador central. Aplica as diretrizes contidas nos arquivos de _playbooks_ habilitados (i.e., presentes no diretório `playbooks-enabled`), seguindo a ordem de nomeclatura dos _playbooks_. Logo no início serão feitas solicitações do login/senha do usuário administrador previamente configurado, seguida de solicitações dos login/senha dos demais usuários exigidos (_"profdtl", "profdcc", "alunodtl", "alunodcc", "profext", "extensao"_), bem como das credenciais do usuário root dos bancos de dados. Serão criados arquivos no diretório `keys` que armazenarão estas informações.
   Este script é o mais frequente a ser chamado, pois poderá ter que ser repetido em caso de erros durante a execução de alguma etapa da instalação/configuração nos computadores remotos, mas as solicitações das credenciais dos usuários não serão obrigatoriamente repetidas.
   ```
   ./04_run_install_lab.sh
   ```
