extends Node

var texts := {
	"eng": {
		"NULL": "",
		
		"JOGAR": "PLAY",
		"CONFIG": "SETTINGS",
		"HISTORIA": "STORY",
		"CREDITOS": "CREDITS",
		"FECHAR": "CLOSE",
		"INFO": "INFO",
		"FASES": "LEVELS",
		"LOG": "CREATE PERFORMANCE LOG",

		"OBG_TEXTO1": "[wave]Thank you for playing\nour game![/wave]",
		"OBG_TEXTO2": "[wave]Follow us on Instagram:\n[color=#9751dd]@finallevel_studio[/color][/wave]",
		"MUNICAO_LABEL": "AMMO",
		"TEMPO": "TIME",
		"KILLS": "KILLS",
		"RETRY": "Try Again",
		"RESTART": "Restart Level",
		"MAINMENU": "Go Back To Menu",
		"VOLTAR": "Go Back",
		
		"BOTAO_OLHAR": "LOOK",
		"BOTAO_PULAR": "JUMP",
		"BOTAO_ATIRAR": "SHOOT",
		"BOTAO_DASH": "DASH",
		"BOTAO_INTE": "INTERACT",
		"BOTAO_PAUSAR": "PAUSE",
		"BOTAO_BATER": "MELEE",
		
		"PONTOS": "POINTS",
		"MORTES": "DEATHS",
		"RANK": "RANK",
		"CONTINUAR": "CONTINUE",
		"NIVEIS": "LEVELS",
		
		"MESTRE": "Master",
		"SONS": "Sound",
		
		"PICKLEVEL": "PICK A LEVEL",
		
		"FASE0": "LEVEL 0",
		"FASE1": "LEVEL 1",
		"FASE2": "LEVEL 2",
		"FASE3": "LEVEL 3",

		"NOME_FASE0": "The Tutorial",
		"NOME_FASE1": "",
		"NOME_FASE2": "",
		"NOME_FASE3": ""
	
	
	},

	"ptbr": {
		"NULL": "",
		
		"JOGAR": "JOGAR",
		"CONFIG": "CONFIG",
		"HISTORIA": "HISTÓRIA",
		"CREDITOS": "CRÉDITOS",
		"FECHAR": "FECHAR",
		"INFO": "INFO",
		"FASES": "FASES",
		"LOG": "GERAR LOG DE DESEMPENHO",

		"OBG_TEXTO1": "[wave]Obrigado por testar \nnosso jogo![/wave]",
		"OBG_TEXTO2": "[wave]Acompanhe no Instagram:\n[color=#9751dd]@finallevel_studio[/color][/wave]",
		"MUNICAO_LABEL": "MUNIÇÃO",
		"TEMPO": "TEMPO",
		"KILLS": "ELIMINAÇÕES",
		"RETRY": "Tentar Novamente",
		"RESTART": "Reiniciar Fase",
		"MAINMENU": "Voltar Ao Menu",
		"VOLTAR": "Voltar",
		
		"BOTAO_OLHAR": "OLHAR",
		"BOTAO_PULAR": "PULAR",
		"BOTAO_ATIRAR": "ATIRAR",
		"BOTAO_DASH": "DASH",
		"BOTAO_INTE": "INTERAGIR",
		"BOTAO_PAUSAR": "PAUSAR",
		"BOTAO_BATER": "BATER",
		
		"PONTOS": "PONTOS",
		"MORTES": "MORTES",
		"RANK": "RANK",
		"CONTINUAR": "CONTINUAR",
		"NIVEIS": "FASES",
		
		"MESTRE": "Mestre",
		"SONS": "Sons",
		
		"PICKLEVEL": "SELECIONE A FASE",
		
		"FASE0": "FASE 0",
		"FASE1": "FASE 1",
		"FASE2": "FASE 2",
		"FASE3": "FASE 3",
		
		"NOME_FASE0": "O Tutorial",
		"NOME_FASE1": "",
		"NOME_FASE2": "",
		"NOME_FASE3": ""


	}
}

func get_text(key: String) -> String:
	return texts.get(Global.lingua, {}).get(key, "[MISSING UI TEXT: %s]" % key)
