# MazyOS Scraper

Ferramenta que busca empresas no Google Maps por nicho e bairro e mostra num mapa, num painel de leads e numa planilha pronta pro Excel. É um fork do [gosom/google-maps-scraper](https://github.com/gosom/google-maps-scraper) (Go, licença MIT) com interface nova em português e uma correção pro Windows.

Quem usa este repositório normalmente não é programador. Fale em português, explique o que está fazendo em linguagem simples e não peça pra pessoa rodar comando que você mesmo pode rodar.

## Quando pedirem pra instalar ou abrir

Rode o script da plataforma, a partir da raiz do repositório:

- **Windows:** `powershell -ExecutionPolicy Bypass -File instalar.ps1`
  Baixa o `mazyos-scraper.exe` pronto do último Release. Se não houver Release, instala o Go na pasta do usuário e compila. No fim, abre o `Abrir MazyOS Scraper.cmd`, que sobe o servidor minimizado e abre `http://localhost:8080`.
- **Mac / Linux:** `bash instalar.sh` e depois `bash abrir.sh`.
  Instala o Go em `~/.mazyos-go` se faltar, compila e sobe o servidor em segundo plano.

A primeira busca baixa sozinha um navegador do Playwright (uns 150 MB). Isso é normal e acontece uma vez só.

Depois de abrir, explique pra pessoa como usar a tela (resumo na seção "Como usar" do `README.md`) e como abrir de novo outro dia (dois cliques em `Abrir MazyOS Scraper.cmd` no Windows, `bash abrir.sh` no Mac/Linux).

## Problemas conhecidos

- **Porta 8080 ocupada:** suba com outra porta, trocando `-addr :8080` por `-addr :8090` no atalho, e abra `http://localhost:8090`.
- **Windows: "O Windows protegeu o computador"** ao abrir o `.exe`: o executável não tem assinatura digital. Oriente a clicar em "Mais informações" e "Executar assim mesmo".
- **Linux: o navegador do Playwright não abre** por falta de biblioteca do sistema: `npx playwright install-deps chromium` (pede sudo).
- **Busca volta vazia com "unexpected page type":** é o bug do binário oficial do gosom no Windows. Confirme que o executável em uso é o `mazyos-scraper.exe` deste repositório, compilado com a correção em `third_party/scrapemate`.
- **Captcha ou bloqueio do Google:** volume alto demais de buscas. Esperar algumas horas e reduzir a quantidade.

## Usar sem a interface (linha de comando)

Pra gerar uma planilha direto, sem abrir o navegador:

```
mazyos-scraper -input buscas.txt -results leads.csv -lang pt -depth 5 -exit-on-inactivity 1m
```

`buscas.txt` tem uma busca por linha ("dentista em Batel, Curitiba"). No Windows, grave esse arquivo **sem BOM** (`[IO.File]::WriteAllText(caminho, texto, (New-Object Text.UTF8Encoding $false))`): o BOM entra na URL e a busca falha. Esse CSV sai no formato cru (vírgula, colunas em inglês). A planilha em português é a do botão "Baixar planilha" no painel.

## Onde mexer no código

- Interface: `web/static/templates/index.html`, `web/static/css/mazyos.css`, `web/static/js/mazyos.js`. Ficam embutidos no executável, então qualquer mudança exige compilar de novo (`go build -o mazyos-scraper.exe .`) com o servidor desligado.
- Rota `GET /api/v1/jobs/{id}/places` (empresas de uma busca em JSON): `web/web.go` e `web/places.go`.
- Correção do Windows (`--single-process` só no Linux): `third_party/scrapemate/adapters/fetchers/jshttp/jshttp.go`, ligada pelo `replace` no `go.mod`.
- Todas as flags de linha de comando: `README-original.md`.

## Uso responsável

Coletar dados do Google Maps automaticamente vai contra os termos de uso do Google. Se a pessoa pedir volume grande (centenas de buscas), avise do risco de bloqueio. Pra abordar os contatos, lembre da LGPD: se identificar, dizer onde achou o contato e tirar da lista quem pedir.
