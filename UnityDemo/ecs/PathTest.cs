
using System;
using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;
using Unity.Mathematics;
using UnityEngine;

namespace P4
{
    [BurstCompile]
    public struct PathFindJob : IJob
    {
        public int2 startPos, endPos;
        public void Execute()
        {
            FindPath(startPos,endPos);
        }

        public void FindPath(int2 startPos, int2 endPos)
        {
            var nodeOffset = new NativeArray<int2>(8, Allocator.Temp);
            nodeOffset[0] = new int2(-1, 0);
            nodeOffset[0] = new int2(1, 0);
            nodeOffset[0] = new int2(0, -1);
            nodeOffset[0] = new int2(0, 1);
            nodeOffset[0] = new int2(-1, -1);
            nodeOffset[0] = new int2(-1, 1);
            nodeOffset[0] = new int2(1, -1);
            nodeOffset[0] = new int2(1, 1);

            var gridSize = new int2(100, 100);

            NativeArray<PathNode> pathNodes = new NativeArray<PathNode>(gridSize.x * gridSize.y, Allocator.Temp);
            for (int x = 0; x < gridSize.x; x++)
            {
                for (int y = 0; y < gridSize.y; y++)
                {
                    var node = new PathNode();
                    node.pos = new int2(x, y);
                    node.index = CalculateIndex(x, y, gridSize.x);
                    node.gCost = int.MaxValue;
                    node.isWalkable = true;
                    node.previousNodeIndex = -1;

                    pathNodes[node.index] = node;
                }
            }

            var openList = new NativeList<int>(Allocator.Temp);
            var closedList = new NativeList<int>(Allocator.Temp);

            var startNodeIndex = CalculateIndex(startPos.x, startPos.y, gridSize.x);
            var startNode = pathNodes[startNodeIndex];
            startNode.gCost = 0;
            startNode.hCost = CalculateDistanceCost(startPos, endPos);
            startNode.CalculateF();
            pathNodes[startNodeIndex] = startNode;

            openList.Add(startNodeIndex);

            var endNodeIndex = CalculateIndex(endPos.x, endPos.y, gridSize.x);

            while (openList.Length > 0)
            {
                var curNode = CalculateMinFNode(ref openList, ref pathNodes);
                if (curNode.index == endNodeIndex)
                    break;

                for (int i = 0; i < openList.Length; i++)
                {
                    if (openList[i] == curNode.index)
                    {
                        openList.RemoveAtSwapBack(i);
                        break;
                    }
                }

                closedList.Add(curNode.index);

                //check neighbour node
                for (int i = 0; i < nodeOffset.Length; i++)
                {
                    var offsetPos = nodeOffset[i];
                    var neighbourNodePos = new int2(curNode.pos.x + offsetPos.x, curNode.pos.y + offsetPos.y);

                    if (!IsPosInsideGrid(neighbourNodePos, gridSize))
                        continue;

                    var neighbourNodeIndex = CalculateIndex(neighbourNodePos.x, neighbourNodePos.y, gridSize.x);
                    if (closedList.Contains(neighbourNodeIndex))
                        continue;
                    
                    var neighbourNode = pathNodes[neighbourNodeIndex];
                    if (!neighbourNode.isWalkable)
                        continue;

                    //check g
                    var tentativeG = curNode.gCost + CalculateDistanceCost(curNode.pos, neighbourNodePos);
                    if (tentativeG < neighbourNode.gCost)
                    {
                        neighbourNode.hCost = CalculateDistanceCost(neighbourNode.pos, endPos);
                        neighbourNode.gCost = tentativeG;
                        neighbourNode.CalculateF();
                        neighbourNode.previousNodeIndex = curNode.index;
                        pathNodes[neighbourNodeIndex] = neighbourNode;

                        if (!openList.Contains(neighbourNodeIndex))
                            openList.Add(neighbourNodeIndex);
                    }
                }
            }

            var endNode = pathNodes[endNodeIndex];
            if (endNode.previousNodeIndex == -1)
            {
                //Debug.Log("not found");
            }
            else
            {
                var paths = CalculatePath(endNode, pathNodes);
                //foreach (var item in paths)
                //{
                //    Debug.Log(item);
                //}
            }

            openList.Dispose();
            closedList.Dispose();
            pathNodes.Dispose();
            nodeOffset.Dispose();
        }

        NativeList<int2> CalculatePath(PathNode endNode, NativeArray<PathNode> pathNodes)
        {
            var list = new NativeList<int2>(Allocator.Temp);
            while (endNode.previousNodeIndex != -1)
            {
                list.Add(endNode.pos);
                endNode = pathNodes[endNode.previousNodeIndex];
            }
            return list;
        }

        private int CalculateDistanceCost(int2 a, int2 b)
        {
            const int DIAGONAL_COST = 14;
            const int STRAIGHT_COST = 10;
            var xDist = math.abs(a.x - b.x);
            var yDist = math.abs(a.y - b.y);
            var remaining = math.abs(xDist - yDist);
            return DIAGONAL_COST * math.min(xDist, yDist) + STRAIGHT_COST * remaining;
        }

        private bool IsPosInsideGrid(int2 pos, int2 gridSize)
        {
            return pos.x >= 0 && pos.y >= 0 && pos.x < gridSize.x && pos.y < gridSize.y;
        }

        private PathNode CalculateMinFNode(ref NativeList<int> openList, ref NativeArray<PathNode> pathNodes)
        {
            var min = pathNodes[openList[0]];
            for (int i = 1; i < openList.Length; i++)
            {
                var node = pathNodes[openList[i]];
                if (node.fCost < min.fCost)
                    min = node;
            }
            return min;
        }

        int CalculateIndex(int x, int y, int width)
        {
            return x + y * width;
        }
    }
    public class PathTest : MonoBehaviour
    {
        NativeArray<int2> nodeOffset;
        private void Start()
        {
            nodeOffset = new NativeArray<int2>(new[] {
                new int2(-1,0),
                new int2(1,0),
                new int2(0,-1),
                new int2(0,1),
                new int2(-1,-1),
                new int2(-1,1),
                new int2(1,-1),
                new int2(1,1),
            }, Allocator.Persistent);

            //FindPath(new int2(),new int2(1,3),nodeOffset);
        }

        private void Update()
        {
            var time = Time.realtimeSinceStartup;

            var jobArr = new NativeArray<JobHandle>(10, Allocator.TempJob);

            for (int i = 0; i < jobArr.Length; i++)
            {

                var startPos = new int2(UnityEngine.Random.Range(0, 100), UnityEngine.Random.Range(0, 100));
                var endPos = new int2(UnityEngine.Random.Range(0, 100), UnityEngine.Random.Range(0, 100));

                jobArr[i] = new PathFindJob { startPos = startPos, endPos = endPos}.Schedule();
            }
            JobHandle.CompleteAll(jobArr);
            Debug.Log((Time.realtimeSinceStartup - time) * 1000 + "ms");

            jobArr.Dispose();
        }

        private void OnDestroy()
        {
            nodeOffset.Dispose();
        }


        

    }

    public struct PathNode
    {
        public int2 pos;
        public int index;
        public int previousNodeIndex;
        public int gCost,hCost,fCost;
        public bool isWalkable;

        public void CalculateF()
        {
            fCost = gCost + hCost;
        }
    }
}