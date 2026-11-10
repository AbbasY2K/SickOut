
extends Node

var texts := {
	"eng": {
		"KILL_1": "[shake rate=18 level=4]EMPLOYEE DISABLED[/shake]",
		"KILL_2": "HR HAS BEEN NOTIFIED",
		"KILL_3": "[shake rate=12 level=3]SUBJECT OUT OF OPERATION[/shake]",
		"KILL_4": "[shake rate=22 level=5]ERROR 404: GUARD NOT FOUND[/shake]",
		"KILL_5": "SUBJECT LOST WILL TO LIVE",
		"KILL_6": "[shake rate=8 level=2]INVESTMENT LOST[/shake]",
		"KILL_7": "[shake rate=16 level=4]TRANSFERRED TO BIOLOGICAL WASTE[/shake]",
		"KILL_8": "WARRANTY VOIDED",
		"KILL_9": "[wave amp=8 freq=4]SOMEONE WILL HAVE TO CLEAN THAT[/wave]",
		"KILL_10": "BADGE RETURNED",
		"KILL_11": "SECURITY BUDGET CUT",
		"KILL_12": "[shake rate=20 level=4]STATUS: VERY DEAD[/shake]",
		"KILL_13": "EX-EMPLOYEE DETECTED",

		"KILL_14": "[shake rate=12 level=3]UGLY SCENE.[/shake]",
		"KILL_15": "[wave amp=5 freq=5]OOPS.[/wave]",
		"KILL_16": "NOT MUCH LEFT.",
		"KILL_17": "[wave amp=7 freq=4]THAT’S GONNA STAIN.[/wave]",
		"KILL_18": "ANOTHER ONE?",
		"KILL_19": "HE TRIED.",
		"KILL_20": "[wave amp=4 freq=3]WHAT A SHAME.[/wave]",
		"KILL_21": "[shake rate=8 level=2]NOT ANYMORE.[/shake]",
		"KILL_22": "[shake rate=18 level=4]THIS GOT PERSONAL.[/shake]",

		"KILL_23": "HE HAD WEEKEND PLANS",
		"KILL_24": "THIS GOES IN THE REPORT",
		"KILL_25": "[shake rate=20 level=5]WRONG BUTTON WAS PRESSED[/shake]",
		"KILL_26": "THE UNION WILL HEAR ABOUT THIS",
		"KILL_27": "[wave amp=6 freq=4]FASTER THAN EVOLUTION[/wave]",
		"KILL_28": "SCIENTISTS DISAPPOINTED",
		"KILL_29": "[shake rate=12 level=3]PLEASE DO NOT REPEAT (REPEAT)[/shake]",
		"KILL_30": "[wave amp=5 freq=3]SUCCESSFUL TEST (?)[/wave]",
		"KILL_31": "THANK YOU FOR PARTICIPATING",
		"KILL_32": "[shake rate=10 level=2]PREMIUM SUBSCRIPTION CANCELLED[/shake]"
	},

	"ptbr": {
		"KILL_1": "[shake rate=18 level=4]FUNCIONÁRIO DESLIGADO[/shake]",
		"KILL_2": "RECURSOS HUMANOS NOTIFICADOS",
		"KILL_3": "[shake rate=12 level=3]COBAIA FORA DE OPERAÇÃO[/shake]",
		"KILL_4": "[shake rate=22 level=5]ERRO 404: GUARDA NÃO ENCONTRADO[/shake]",
		"KILL_5": "PACIENTE PERDEU O INTERESSE EM VIVER",
		"KILL_6": "[shake rate=8 level=2]INVESTIMENTO PERDIDO[/shake]",
		"KILL_7": "[shake rate=16 level=4]SUJEITO ENCAMINHADO AO LIXO BIOLÓGICO[/shake]",
		"KILL_8": "GARANTIA ANULADA",
		"KILL_9": "[wave amp=8 freq=4]ALGUÉM VAI TER QUE LIMPAR ISSO[/wave]",
		"KILL_10": "SUJEITO DEVOLVEU O CRACHÁ",
		"KILL_11": "ORÇAMENTO DE SEGURANÇA REDUZIDO",
		"KILL_12": "[shake rate=20 level=4]STATUS: BASTANTE MORTO[/shake]",
		"KILL_13": "EX-COLABORADOR DETECTADO",

		"KILL_14": "[shake rate=12 level=3]COISA FEIA.[/shake]",
		"KILL_15": "[wave amp=5 freq=5]OPS.[/wave]",
		"KILL_16": "NÃO SOBROU MUITO.",
		"KILL_17": "[wave amp=7 freq=4]ISSO DEIXA MANCHA.[/wave]",
		"KILL_18": "OUTRO?",
		"KILL_19": "ELE TENTOU.",
		"KILL_20": "[wave amp=4 freq=3]QUE PENA.[/wave]",
		"KILL_21": "[shake rate=8 level=2]NÃO MAIS.[/shake]",
		"KILL_22": "[shake rate=18 level=4]FICOU PESSOAL.[/shake]",

		"KILL_23": "ELE TINHA PLANOS PARA O FIM DE SEMANA",
		"KILL_24": "ISSO VAI NO RELATÓRIO",
		"KILL_25": "[shake rate=20 level=5]NÃO ERA ESSE O BOTÃO[/shake]",
		"KILL_26": "O SINDICATO VAI OUVIR FALAR DISSO",
		"KILL_27": "[wave amp=6 freq=4]MAIS RÁPIDO QUE A EVOLUÇÃO[/wave]",
		"KILL_28": "CIENTISTAS DESAPONTADOS",
		"KILL_29": "[shake rate=12 level=3]FAVOR NÃO REPETIR (REPITA)[/shake]",
		"KILL_30": "[wave amp=5 freq=3]TESTE BEM-SUCEDIDO (?)[/wave]",
		"KILL_31": "OBRIGADO POR PARTICIPAR",
		"KILL_32": "[shake rate=10 level=2]ASSINATURA PREMIUM CANCELADA[/shake]"
	}
}

func get_text(key: String) -> String:
	return texts.get(Global.lingua, {}).get(key, "[MISSING UI TEXT: %s]" % key)
