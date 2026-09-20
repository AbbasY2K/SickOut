extends Node

var texts := {
	"eng": {
		"RESUMO": """
Two scientists operate an underground complex officially presented as a maximum-security prison. In reality, it is a clandestine laboratory where inmates are used as test subjects in biochemical and genetic experiments.

The prison guards undergo cybernetic enhancements that make them stronger, tougher, and completely loyal, turning the facility's own security force into part of the project.

The scientists' true objective is to accelerate human evolution by creating a new hybrid generation—biologically and technologically enhanced—capable of replacing ordinary humans.

Mike discovers that his brother has been taken to this prison. However, when he tries to visit him, he finds that there is no record of his existence anywhere in the system.

While investigating the prison's past, Mike learns that the site once housed a secret laboratory that was shut down after a mysterious incident. Convinced that his brother is being held in hidden underground levels, he deliberately commits a crime in order to be arrested and infiltrate the complex.

Now, Mike must fight his way through the prison's security levels, uncover the truth behind the experiments, and eliminate everyone responsible for his brother's disappearance.
""",

		"CREDITOS_CEO": """
[wave][font_size=40][color=#ef3e3e]CEO[/color][/font_size][/wave]
Lorena Goes
""",

		"CREDITOS_GESTORES": """
[wave][font_size=40][color=#f5c16c]MANAGERS[/color][/font_size][/wave]
André Nóbrega
Alberto Barbosa
""",

		"CREDITOS_PROGRAMACAO": """
[wave][font_size=40][color=#6cc6f5]PROGRAMMING[/color][/font_size][/wave]
Johnny Abbas
""",

		"CREDITOS_ARTE": """
[wave][font_size=40][color=#ff8bd1]ART[/color][/font_size][/wave]
Miguel Lacerda
Pedro Richter
Madilene Pavão
Kamilly Barros
""",

		"CREDITOS_GAME_DESIGN": """
[wave][font_size=40][color=#8dffb1]GAME DESIGN[/color][/font_size][/wave]
Pedro Xavier
Pedro Linhares
Leonardo Mendes
""",

		"CREDITOS_MARKETING": """
[wave][font_size=40][color=#ff9f6c]MARKETING[/color][/font_size][/wave]
Ingrid Cristini
Sara Garcia
Cauã Goudard
Danielle Santos
""",

		"CREDITOS_BETA": """
[center]
[font_size=40][color=#c8a2ff][wave]BETA TESTERS[/wave][/color][/font_size]
[font_size=24]
Júlia Araújo
Maria Camilo
Nicole Victoria
Isaac Dias
Eufrasio Marinho
Lucas Albuquerque
[/font_size]
[/center]
""",

"CREDITOS_BETA_2": """
[center]
[font_size=24]
Vitoria Ferreira
Miguel Mello
Mariana Mata
Félix Mata
Rafael Rezende
[/font_size]
[/center]
""",

		"CREDITOS_AGRADECIMENTOS": """
[wave][font_size=40][color=#ff64ff]SPECIAL THANKS[/color][/font_size][/wave]

Gabriella De Assis
""",

		"FASE0_DESC": "Review the game's basics.",
		"FASE1_DESC": "Explore the facility and rescue Mike!",
		"FASE2_DESC": "Explore the facility and rescue Mike!",
		"FASE3_DESC": "Explore the facility and rescue Mike!",
		"FASE4_DESC": "Coming Soon...",
		"FASE5_DESC": "Coming Soon...",
		"FASE6_DESC": "Coming Soon...",
		"FASE7_DESC": "Coming Soon...",
		"FASE8_DESC": "Coming Soon...",
		"FASE9_DESC": "Coming Soon..."
	},

	"ptbr": {
		"RESUMO": """
Dois cientistas comandam um complexo subterrâneo que funciona oficialmente como uma prisão de segurança máxima. Na realidade, o local é um laboratório clandestino onde detentos são usados como cobaias em experimentos bioquímicos e genéticos.

Os guardas passam por modificações cibernéticas que os tornam mais fortes, resistentes e leais, transformando a própria segurança do presídio em parte do projeto.

O verdadeiro objetivo dos cientistas é acelerar a evolução humana, criando uma nova geração híbrida — biologicamente e tecnologicamente aprimorada — capaz de substituir o ser humano comum.

Mike descobre que seu irmão foi levado para essa prisão. Porém, ao tentar visitá-lo, percebe que não existe qualquer registro de sua presença no sistema.

Investigando o passado do local, Mike descobre que o terreno já abrigou um laboratório secreto, fechado após um incidente misterioso. Convencido de que seu irmão pode estar escondido em níveis subterrâneos ocultos, ele comete um crime propositalmente para ser preso e se infiltrar no complexo.

Agora, seu objetivo é descer pelos níveis de segurança, descobrir a verdade por trás dos experimentos e eliminar todos os responsáveis pelo desaparecimento de seu irmão.
""",

		"CREDITOS_CEO": """
[wave][font_size=50][color=#ef3e3e]CEO[/color][/font_size][/wave]
Lorena Goes
""",

		"CREDITOS_GESTORES": """
[wave][font_size=50][color=#f5c16c]GESTORES[/color][/font_size][/wave]
André Nóbrega
Alberto Barbosa
""",

		"CREDITOS_PROGRAMACAO": """
[wave][font_size=50][color=#6cc6f5]PROGRAMAÇÃO[/color][/font_size][/wave]
Johnny Abbas
""",

		"CREDITOS_ARTE": """
[wave][font_size=50][color=#ff8bd1]ARTE[/color][/font_size][/wave]
Miguel Lacerda
Pedro Richter
Madilene Pavão
Kamilly Barros
""",

		"CREDITOS_GAME_DESIGN": """
[wave][font_size=50][color=#8dffb1]GAME DESIGN[/color][/font_size][/wave]
Pedro Xavier
Pedro Linhares
Leonardo Mendes
""",

		"CREDITOS_MARKETING": """
[wave][font_size=50][color=#ff9f6c]MARKETING[/color][/font_size][/wave]
Ingrid Cristini
Sara Garcia
Cauã Goudard
Danielle Santos
""",

		"CREDITOS_BETA": """
[center]
[font_size=40][color=#c8a2ff][wave]BETA TESTERS[/wave][/color][/font_size]
[font_size=24]
Júlia Araújo
Maria Camilo
Nicole Victoria
Isaac Dias
Eufrasio Marinho
Lucas Albuquerque
[/font_size]
[/center]
""",

"CREDITOS_BETA_2": """
[center]
[font_size=24]
Vitoria Ferreira
Miguel Mello
Mariana Mata
Félix Mata
Rafael Rezende
[/font_size]
[/center]
""",

		"CREDITOS_AGRADECIMENTOS": """
[wave][font_size=40][color=#ff64ff]AGRADECIMENTOS ESPECIAIS[/color][/font_size][/wave]
Gabriella De Assis
""",

		"FASE0_DESC": "Revise as mecânicas básicas do jogo.",
		"FASE1_DESC": "Explore a prisão e busque o Mike!",
		"FASE2_DESC": "Explore a prisão e busque o Mike!",
		"FASE3_DESC": "Explore a prisão e busque o Mike!",
		"FASE4_DESC": "Em Breve...",
		"FASE5_DESC": "Em Breve...",
		"FASE6_DESC": "Em Breve...",
		"FASE7_DESC": "Em Breve...",
		"FASE8_DESC": "Em Breve...",
		"FASE9_DESC": "Em Breve..."
	}
}


func get_text(key: String) -> String:
	return texts.get(Global.lingua, {}).get(
		key,
		"[MISSING STORY TEXT: %s]" % key
	)
