// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

// pageextension 50003 CustomerListExt extends "Customer List"
// {
//     trigger OnOpenPage();
//     var
//         crypto: Codeunit "Cryptography Management";
//     begin
//         Message('App published: Hello world: %1', crypto.GenerateHash('qweqweqweqweq', 2));
//     end;
// }