LuaQ     @spectate_c.lua           )      A@  �@  �@  � A�  ��  �    @� ܀��$       �           �  �  �dC  ��     ��    �$         �  �     �      �  �     �   D  �       tocolor      �o@   bankgothic �������?   dxGetFontHeight    initSpectate        
   *     A      E@  ��  ��D   K�� �   \@�D � K�� �   \@�@    � � E  \�� Z    ��@ � � �� �A� ��� � � �� @  Z   @��  � � �� � � �@�A� � U���@�� �� � �@B� �@��  �   � �� �� C�@ � ��  � C�@ � ��   � ��  � C�@ � �� �� C�@  �       getElementData    g_Me    race.spectating    setVisible    getCameraTarget    getElementType    vehicle    getVehicleOccupant    getPlayerName    setText    Spectating     No one to spectate    render     A                                                                                                                                                                "   "   "   %   %   %   &   &   &   &   (   (   (   *      	   specMode    @      target    @      targetName !   '         g_SpecModeLabel    g_SpecModeTargetLabel    g_SpecPrevActive    g_SpecPrevActiveImg    g_SpecPrevImg    g_SpecNextActive    g_SpecNextActiveImg    g_SpecNextImg     ,   /            �� E@  �   \@  �       isSpectateModeEnabled    setSpectateModeEnabled        -   -   .   .   .   /         enabled               1   7    
   W �   ��@  � � �   @� @ ���  �@�  �       down    up    spectatePrev     
   2   2   2   2   2   4   4   5   5   7         key     	   	   keyState     	         g_SpecPrevActive     9   ?    
   W �   ��@  � � �   @� @ ���  �@�  �       down    up    spectateNext     
   :   :   :   :   :   <   <   =   =   ?         key     	   	   keyState     	         g_SpecNextActive     A   _     �      @@ A�  �       �@ �  �@A��A�   ����� �  �@�  �BAA� �@    @@ A� �  �  � �@ �  �@A��A�   ����� �  �@�  �BAA� �@    @@ A  �     �@ �  �@A��A�  �@� �BAA� �@    @@ A@ �  � ��@ �  �@A��A�  �@� �BAA� �@ � @@ A� �  �@  A �     @D �� @�  �D � ��  @    E �   @�  @E �� @�� @@ A� �  �  �@� �� � �@D �� @� � F �� @� ��D � ��  @  �@F �   @� � E �   @�� A� �  �  @ � A@ �� � �@ � A� �� �  @   A@ �� � �@  � #      DxImg    create    img/specprev.png    setPos    g_ScrW        @      i@   w    g_ScrH       Y@   h    img/specprev_hi.png    img/specnext.png    img/specnext_hi.png    DxLabel    Spectate Mode         	   setAlign    center    setFont    setVisible 
   setBorder       �?       setVerticalAlign    setColorCoded    bindKey    b    down    arrow_l    both    arrow_r    addEventHandler    onClientRender    g_Root     �   B   B   B   B   B   C   C   C   C   C   C   C   C   C   C   C   C   C   C   C   D   D   D   D   D   E   E   E   E   E   E   E   E   E   E   E   E   E   E   E   G   G   G   G   G   H   H   H   H   H   H   H   H   H   H   H   H   I   I   I   I   I   J   J   J   J   J   J   J   J   J   J   J   J   L   L   L   L   L   L   L   L   L   M   M   M   M   N   N   N   N   N   O   O   O   O   P   P   P   P   S   S   S   S   S   S   S   S   S   T   T   T   T   U   U   U   U   V   V   V   V   V   W   W   W   W   X   X   X   X   Z   Z   Z   Z   Z   [   [   [   [   [   \   \   \   \   \   ^   ^   ^   ^   ^   _             g_SpecPrevImg    g_SpecPrevActiveImg    g_SpecNextImg    g_SpecNextActiveImg    g_SpecModeLabel    g_Font    g_FontScale    g_SpecModeTargetLabel 	   spectate    spectatePrevReq    spectateNextReq    rednerSpectate )                                       *   *   *   *   *   *   *   *   *   /   7   7   ?   ?   _   _   _   _   _   _   _   _   _   _   _   _   _   A   _         g_White    (      g_Font    (      g_FontScale    (      g_FontHeight    (      g_SpecPrevImg    (      g_SpecNextImg    (      g_SpecPrevActiveImg    (      g_SpecNextActiveImg    (      g_SpecPrevActive    (      g_SpecNextActive    (      g_SpecModeLabel    (      g_SpecModeTargetLabel    (      rednerSpectate    (   	   spectate    (      spectatePrevReq    (      spectateNextReq    (       