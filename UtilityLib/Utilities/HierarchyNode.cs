using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UtilityLib.Utilities
{
    /// <summary>
    /// 可以行为层次的Node
    /// var rootNode = new Node(0); //depth=0
    /// var classNode = rootNode.NewNode(); //depth=1
    /// </summary>
    public class HierarchyNode
    {
        public int depth;
        static StringBuilder stringBuilder = new StringBuilder();
        public List<HierarchyNode> children = new List<HierarchyNode>();

        public HierarchyNode(int depth)
        {
            this.depth = depth;
        }

        public void Clear()
        {
            stringBuilder.Clear();
        }

        public HierarchyNode NewNode()
        {
            var node = new HierarchyNode(depth + 1);
            children.Add(node);
            return node;
        }

        public override string ToString()
        {
            return stringBuilder.ToString();
        }
        public HierarchyNode Append(string value="",bool addIndent=true)
        {
            if(addIndent)
                stringBuilder.AddIndent(depth);
            stringBuilder.Append(value);
            return this;
        }

        public HierarchyNode AppendLine(string value = "", bool addIndent = true)
        {
            if (addIndent)
                stringBuilder.AddIndent(depth);
            stringBuilder.AppendLine(value);
            return this;
        }

    }
}
