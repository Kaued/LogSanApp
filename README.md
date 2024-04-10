# LogSanApp

LogSanApp é um aplicativo desenvolvido em Flutter que permite aos usuários criar rotas com ordens de serviço e designá-las para outros usuários. O aplicativo utiliza o Firebase para armazenamento de dados em tempo real, oferecendo uma experiência colaborativa e em tempo real para gerenciamento de rotas e ordens de serviço.

## Funcionalidades Principais

- **Criação de Rotas:** Os usuários podem criar rotas definindo locais e pontos de parada.
- **Ordens de Serviço:** É possível associar ordens de serviço a cada ponto de parada em uma rota.
- **Designação de Tarefas:** Os usuários podem atribuir ordens de serviço a outros usuários.
- **Notificações em Tempo Real:** O Firebase permite notificações em tempo real para atualizações de rotas e ordens de serviço.

## Como Utilizar

Para utilizar o repositório e executar o aplicativo localmente, siga estas instruções:

### Pré-requisitos

- Flutter SDK instalado: [Flutter Install Instructions](https://flutter.dev/docs/get-started/install)
- Um editor de código, como o Visual Studio Code ou o Android Studio, com os plugins necessários para desenvolvimento Flutter.
- Conta no Firebase e projeto configurado: [Firebase Console](https://console.firebase.google.com/)

### Passos de Instalação

1. Clone o repositório do GitHub:

   ```bash
   git clone https://github.com/seu-usuario/LogSanApp.git
   ```

2. Abra o projeto no seu editor de código.

3. Configure o Firebase para o projeto:
   - Crie um novo projeto no [Firebase Console](https://console.firebase.google.com/).
   - Siga as instruções para adicionar o Firebase ao seu aplicativo Flutter.
   - Baixe o arquivo `google-services.json` e coloque-o na pasta `android/app` do seu projeto.

4. Execute o projeto no seu dispositivo ou emulador:

   ```bash
   flutter run
   ```