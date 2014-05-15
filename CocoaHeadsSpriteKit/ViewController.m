//
//  ViewController.m
//  CocoaHeadsSpriteKit
//
//  Created by Dilson Alkmim on 14/05/14.
//  Copyright (c) 2014 Cocoa Heads. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import "BolaNode.h"

#define kRaioBola   36

@interface ViewController() <SKPhysicsContactDelegate, BolaNodeDelegate> {
    
    SKScene *_scene;
    
    NSMutableArray *_bolas;

    int _placar;
    SKLabelNode *_placarNode;
}

-(void)_adicioneBola;
-(void)_exibaBisbilhoteira;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    _scene = [MyScene sceneWithSize:skView.bounds.size];
    _scene.scaleMode = SKSceneScaleModeAspectFill;
    _scene.physicsWorld.contactDelegate = self;

    //plano de fundo
    SKSpriteNode *fundo = [SKSpriteNode spriteNodeWithImageNamed:@"campo"];
    fundo.size = skView.frame.size;
    fundo.position = skView.center;
    [_scene addChild:fundo];

    _bolas = [NSMutableArray new];
    [self _adicioneBolaRecursivo];
    
    SKShapeNode *chao = [SKShapeNode node];
    chao.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:skView.bounds];
    chao.physicsBody.categoryBitMask = 123;
    [_scene addChild:chao];

    _placarNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    _placarNode.fontSize = 30;
    _placarNode.fontColor = [UIColor whiteColor];
    _placarNode.position = CGPointMake(skView.frame.size.width / 2, skView.frame.size.height - 50);
    [_scene addChild:_placarNode];
    
    //começamos com 0
    [self _atualizePlacar:0];
    
    // Present the scene.
    [skView presentScene:_scene];
    
    [self performSelector:@selector(_exibaBisbilhoteira) withObject:nil afterDelay:5];
}

-(void)_exibaBisbilhoteira
{
    //Gera aleatório entre 1 e 3
    int indiceBisbilhoteira = arc4random_uniform(3) + 1;
    BOOL moverParaDireita = arc4random_uniform(2) == 0;
    
    NSString *arquivoImagem = [NSString stringWithFormat:@"brazuca_bisbilhoteira_%d", indiceBisbilhoteira];

    SKSpriteNode *bisbilhoteira = [SKSpriteNode spriteNodeWithImageNamed:arquivoImagem];
    
    // Se mover da esquerda p/ direita, posiciona
    // a bola antes da área visível do aparelho.
    // Se mover da direita p/ esquerda, posiciona
    // depois da área visível
    CGPoint posicao;
    posicao.x = moverParaDireita
                    ? -bisbilhoteira.size.width / 2
                    :  self.view.bounds.size.width + bisbilhoteira.size.width / 2;
    
    posicao.y = self.view.bounds.size.height - 100;
    
    bisbilhoteira.position = posicao;

    // Girando, girando, girando prum lado.
    SKAction *rolar = [SKAction rotateByAngle:moverParaDireita ? -2 * M_PI : 2 * M_PI
                                     duration:1.5];
    
    // O deslocamento vai acontecer em uma distância igual ao comprimento da tela,
    // acrescido do tamanho da bola. Assim ele sai de posição anterior|posterior
    // à área visível, e finaliza em uma posição posterior|anterior à área visível.
    // Se estiver movendo da direita p/ esquerda, o deltaX é negativo, se estiver
    // movendo da esquerda p/ direita, o deltaX é positivo.
    float deltaX = (self.view.frame.size.width + bisbilhoteira.size.width) * (moverParaDireita ? 1 : -1);
    SKAction *mover = [SKAction moveByX:deltaX y:0 duration:1.5];
    
    SKAction *removerQuandoFinalizar = [SKAction runBlock:^{
        [bisbilhoteira removeFromParent];
    }];
    
    
    // 'group' para realizar as animações 'rola' e 'mover' ao mesmo tempo.
    // 'sequence' para executar uma ação após a outra finalizar.
    SKAction *movimentoCompleto = [SKAction sequence:@[
                                                       [SKAction group:@[rolar, mover]],
                                                       removerQuandoFinalizar
                                                       ]];
    

    // Manda ver!
    [bisbilhoteira runAction:movimentoCompleto];
    
    [_scene addChild:bisbilhoteira];
    
    // Agenda mais uma bisbilhoteira p/ daqui a 5 secs.
    [self performSelector:@selector(_exibaBisbilhoteira) withObject:nil afterDelay:5];
}

-(void)_adicioneBolaRecursivo
{
    [self _adicioneBola];
    [self performSelector:@selector(_adicioneBolaRecursivo) withObject:nil afterDelay:5];
}

-(void)_adicioneBola
{
    BolaNode *bola = [BolaNode spriteNodeWithImageNamed:@"brazuca"];
    bola.userInteractionEnabled = YES;
    bola.delegate = self; //BolaDelegate
    
    //Centraliza horizontalmente, e cai desde o topo
    bola.position = CGPointMake(self.view.frame.size.width / 2,
                                self.view.frame.size.height);
    
    // kRaioBola = raio da bola em pixels (36pt).
    // A imagem possui uma sombra em volta, esses 36pt já descontam
    // o espaço extra em volta da imagem da bola
    bola.physicsBody = [SKPhysicsBody  bodyWithCircleOfRadius:kRaioBola];
    bola.physicsBody.mass = 0.4;
    bola.physicsBody.restitution = 0.6;
    bola.physicsBody.friction = 0.8;
    bola.zPosition = 1000;
    bola.physicsBody.contactTestBitMask = 123;

    [_scene addChild:bola];
    [_bolas addObject:bola];
}

-(void)_atualizePlacar:(int)novoPlacar
{
    _placar = novoPlacar;
    _placarNode.text = [NSString stringWithFormat:@"Placar: %d", _placar];
}

-(void)embaixadinhaRealizada:(BolaNode *)bola
{
    [self _atualizePlacar:_placar+1];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *toque = [touches anyObject];
    
    if(toque.tapCount > 1 && _bolas.count > 1) {
        for(BolaNode *bola in _bolas) {
            [bola removeFromParent];
        }
        
        [_bolas removeAllObjects];
        
        [self _adicioneBola];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    //
    // Se o contato ocorrer quando a posicão central for menor
    // do que o seu raio, significa que foi contra o chão.
    // Outros valores de y significam que a bola
    // se chocou com as paredes laterais ou com o 'teto'.
    //
    if(contact.contactPoint.y < kRaioBola) {
        [self _atualizePlacar:0];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
