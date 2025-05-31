# CEP Fácil

Aplicativo Flutter para consulta e gerenciamento de CEPs usando ViaCEP e Back4App.

## Funcionalidades

- Consulta de CEPs através da API ViaCEP
- Armazenamento automático dos CEPs consultados no Back4App
- Listagem dos CEPs cadastrados
- Exclusão de CEPs cadastrados

## Configuração

1. Clone o repositório
2. Edite o arquivo `.env` na raiz do projeto com as seguintes variáveis:
```
BACK4APP_APPLICATION_ID=seu_application_id
BACK4APP_CLIENT_KEY=seu_client_key
BACK4APP_SERVER_URL=https://parseapi.back4app.com
```
3. Execute `flutter pub get` para instalar as dependências
4. Execute `flutter run` para iniciar o aplicativo

## Configuração do Back4App

1. Crie uma conta no [Back4App](https://www.back4app.com/)
2. Crie um novo aplicativo
3. Na seção "Database" do seu aplicativo, crie uma classe chamada "Cep" com os seguintes campos:
   - cep (String)
   - logradouro (String)
   - bairro (String)
   - cidade (String)
   - uf (String)
4. Copie as credenciais do seu aplicativo (Application ID e Client Key) e adicione ao arquivo `.env`

## Tecnologias utilizadas

- Flutter
- Dio (para requisições HTTP)
- Parse SDK (para integração com Back4App)
- Flutter Dotenv (para gerenciamento de variáveis de ambiente)
